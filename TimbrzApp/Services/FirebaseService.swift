import Foundation
import Combine

protocol AuthServiceProtocol {
    func signInAnonymously() -> AnyPublisher<Void, Error>
    func signOut() -> AnyPublisher<Void, Error>
}

protocol ListingsRepositoryProtocol {
    func fetchListings() -> AnyPublisher<[Listing], Error>
}

final class MockAuthService: AuthServiceProtocol {
    func signInAnonymously() -> AnyPublisher<Void, Error> { Just(()).setFailureType(to: Error.self).eraseToAnyPublisher() }
    func signOut() -> AnyPublisher<Void, Error> { Just(()).setFailureType(to: Error.self).eraseToAnyPublisher() }
}

final class MockListingsRepository: ListingsRepositoryProtocol {
    func fetchListings() -> AnyPublisher<[Listing], Error> {
        Just(Listing.samples).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

// Placeholder for future Firebase-backed services
enum FirebaseService {}
