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

struct TenDayForecastPayload: Equatable {
    let locationName: String
    let days: [WeatherForecastDay]
}

protocol WeatherServicing {
    func weatherPeek(for trip: Trip) async -> WeatherPeek
    func tenDayForecast(for trip: Trip) async -> TenDayForecastPayload?
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

        guard let resolved = await resolver.resolve(destination: trip.destination) else {
            return WeatherPeek(summary: "Weather peek needs a destination location.")
        }

        if let forecast = try? await primary.peek(at: resolved.location, for: trip.startDate) {
            return WeatherPeek(summary: forecast)
        }

        if let mock = try? await fallback.peek(at: resolved.location, for: trip.startDate) {
            return WeatherPeek(summary: mock)
        }

        return WeatherPeek(summary: "Meander tried peeking at the weather, but the clouds were shy.")
    }

    func tenDayForecast(for trip: Trip) async -> TenDayForecastPayload? {
        guard let resolved = await resolver.resolve(destination: trip.destination) else { return nil }

        if let forecast = try? await primary.tenDay(at: resolved.location) {
            return TenDayForecastPayload(locationName: resolved.displayName, days: forecast)
        }

        if let fallbackForecast = try? await fallback.tenDay(at: resolved.location) {
            return TenDayForecastPayload(locationName: resolved.displayName, days: fallbackForecast)
        }

        return nil
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

    struct ResolvedDestination {
        let location: CLLocation
        let displayName: String
    }

    func resolve(destination: String) async -> ResolvedDestination? {
        let trimmed = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        do {
            let placemarks = try await geocoder.geocodeAddressString(trimmed)
            guard let placemark = placemarks.first, let location = placemark.location else { return nil }

            let parts = [
                placemark.locality,
                placemark.administrativeArea,
                placemark.country
            ].compactMap { value -> String? in
                guard let value, !value.isEmpty else { return nil }
                return value
            }

            let displayName = parts.isEmpty ? trimmed : parts.joined(separator: ", ")
            return ResolvedDestination(location: location, displayName: displayName)
        } catch {
            return nil
        }
    }
}

@MainActor
final class TripWeatherViewModel: ObservableObject {
    @Published var weatherLine: String = "Weather peek opens closer to your trip."
    @Published var tenDayForecast: [WeatherForecastDay] = []
    @Published var tenDayLocationName: String?

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
            if let payload = await service.tenDayForecast(for: trip) {
                tenDayLocationName = payload.locationName
                tenDayForecast = payload.days
            } else {
                tenDayLocationName = nil
                tenDayForecast = []
            }
        }
    }
}
