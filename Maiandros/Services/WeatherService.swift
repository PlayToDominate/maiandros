import CoreLocation
import Foundation

struct WeatherPeek: Equatable {
    let summary: String
}

struct WeatherForecastDay: Equatable, Identifiable {
    let id = UUID()
    let date: Date
    let high: Int
    let low: Int
    let condition: String
}

protocol WeatherServicing {
    func weatherPeek(for trip: Trip) async -> WeatherPeek
    func tenDayForecast(for trip: Trip) async -> [WeatherForecastDay]
}

enum WeatherServiceFactory {
    static func make() -> WeatherServicing {
        #if canImport(WeatherKit)
        return WeatherService(primary: WeatherKitProvider(), fallback: MockWeatherProvider())
        #else
        return WeatherService(primary: MockWeatherProvider(), fallback: MockWeatherProvider())
        #endif
    }
}

final class WeatherService: WeatherServicing {
    private let primary: WeatherProviding
    private let fallback: WeatherProviding
    private let resolver = DestinationLocationResolver()

    init(primary: WeatherProviding, fallback: WeatherProviding) {
        self.primary = primary
        self.fallback = fallback
    }

    func weatherPeek(for trip: Trip) async -> WeatherPeek {
        if trip.daysUntilDeparture > 10 {
            return WeatherPeek(summary: "Weather peek opens closer to your trip.")
        }

        guard let location = await resolver.resolve(destination: trip.destination) else {
            return WeatherPeek(summary: "Weather peek needs a destination location.")
        }

        if let forecast = try? await primary.peek(at: location, for: trip.startDate) {
            return WeatherPeek(summary: forecast)
        }

        if let mock = try? await fallback.peek(at: location, for: trip.startDate) {
            return WeatherPeek(summary: mock)
        }

        return WeatherPeek(summary: "Meander tried peeking at the weather, but the clouds were shy.")
    }

    func tenDayForecast(for trip: Trip) async -> [WeatherForecastDay] {
        guard let location = await resolver.resolve(destination: trip.destination) else { return [] }

        if let forecast = try? await primary.tenDay(at: location) {
            return forecast
        }

        if let fallbackForecast = try? await fallback.tenDay(at: location) {
            return fallbackForecast
        }

        return []
    }
}

protocol WeatherProviding {
    func peek(at location: CLLocation, for date: Date) async throws -> String
    func tenDay(at location: CLLocation) async throws -> [WeatherForecastDay]
}

final class MockWeatherProvider: WeatherProviding {
    func peek(at location: CLLocation, for date: Date) async throws -> String {
        let options = [
            "Weather peek: 72° and partly cloudy near departure.",
            "Looks like sweater weather.",
            "Weather peek: mild skies and a small chance of drizzle.",
            "Weather peek: sunshine with a light breeze near departure."
        ]
        return options[abs(Int(location.coordinate.latitude * 10 + location.coordinate.longitude * 10)) % options.count]
    }

    func tenDay(at location: CLLocation) async throws -> [WeatherForecastDay] {
        let baseHigh = 64 + abs(Int(location.coordinate.latitude.rounded())) % 12
        let conditions = ["Sunny", "Partly Cloudy", "Cloudy", "Light Rain", "Breezy", "Clear"]
        let start = Calendar.current.startOfDay(for: Date())

        return (0..<10).compactMap { offset in
            guard let date = Calendar.current.date(byAdding: .day, value: offset, to: start) else { return nil }
            let wiggle = (offset % 5) - 2
            let high = baseHigh + wiggle
            let low = high - 9
            let condition = conditions[(offset + abs(Int(location.coordinate.longitude.rounded()))) % conditions.count]
            return WeatherForecastDay(date: date, high: high, low: low, condition: condition)
        }
    }
}

#if canImport(WeatherKit)
import WeatherKit

@available(iOS 16.0, *)
final class WeatherKitProvider: WeatherProviding {
    private let service = WeatherKit.WeatherService()

    func peek(at location: CLLocation, for date: Date) async throws -> String {
        // TODO: Ensure WeatherKit capability is enabled in Xcode target + Apple Developer portal.
        let weather = try await service.weather(for: location)
        let current = weather.currentWeather
        let temp = Int(current.temperature.value.rounded())
        return "Weather peek: \(temp)° and \(current.condition.description.lowercased()) near departure."
    }

    func tenDay(at location: CLLocation) async throws -> [WeatherForecastDay] {
        // TODO: Ensure WeatherKit capability is enabled in Xcode target + Apple Developer portal.
        let weather = try await service.weather(for: location)
        let days = weather.dailyForecast.forecast.prefix(10)
        return days.map { day in
            WeatherForecastDay(
                date: day.date,
                high: Int(day.highTemperature.value.rounded()),
                low: Int(day.lowTemperature.value.rounded()),
                condition: day.condition.description
            )
        }
    }
}
#endif

actor DestinationLocationResolver {
    private let geocoder = CLGeocoder()

    func resolve(destination: String) async -> CLLocation? {
        let trimmed = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        do {
            let placemarks = try await geocoder.geocodeAddressString(trimmed)
            return placemarks.first?.location
        } catch {
            return nil
        }
    }
}

@MainActor
final class TripWeatherViewModel: ObservableObject {
    @Published var weatherLine: String = "Weather peek opens closer to your trip."
    @Published var tenDayForecast: [WeatherForecastDay] = []

    private let service: WeatherServicing

    init(service: WeatherServicing = WeatherServiceFactory.make()) {
        self.service = service
    }

    func loadWeather(for trip: Trip) {
        Task {
            let peek = await service.weatherPeek(for: trip)
            weatherLine = peek.summary
        }
    }

    func loadTenDay(for trip: Trip) {
        Task {
            tenDayForecast = await service.tenDayForecast(for: trip)
        }
    }
}
