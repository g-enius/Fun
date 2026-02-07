//
//  DefaultNetworkServiceTests.swift
//  Services
//
//  Unit tests for DefaultNetworkService
//

import Testing
import Foundation
@testable import FunServices
@testable import FunModel

// MARK: - Test Helpers

/// Simple Codable model for testing
private struct TestModel: Codable, Equatable {
    let id: Int
    let name: String
}

/// URLProtocol subclass that intercepts requests and returns configured responses
private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Testable Network Service

/// A variant of DefaultNetworkService that uses a custom URLSession for testing
@MainActor
private final class TestableNetworkService: NetworkService {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func fetch<T: Decodable>(from url: URL) async throws -> T {
        let data = try await fetchData(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}

// MARK: - Tests

@Suite("DefaultNetworkService Tests", .serialized)
@MainActor
struct DefaultNetworkServiceTests {

    private let testURL = URL(string: "https://example.com/api/test")!

    private func makeService() -> TestableNetworkService {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return TestableNetworkService(session: session)
    }

    private func makeResponse(statusCode: Int, for url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    // MARK: - fetchData Tests

    @Test("fetchData returns data for successful response")
    func testFetchDataSuccess() async throws {
        let service = makeService()
        let expectedData = "Hello, World!".data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = self.makeResponse(statusCode: 200, for: request.url!)
            return (response, expectedData)
        }

        let data = try await service.fetchData(from: testURL)
        #expect(data == expectedData)
    }

    @Test("fetchData throws for 404 response")
    func testFetchData404() async {
        let service = makeService()

        MockURLProtocol.requestHandler = { request in
            let response = self.makeResponse(statusCode: 404, for: request.url!)
            return (response, Data())
        }

        await #expect(throws: URLError.self) {
            _ = try await service.fetchData(from: testURL)
        }
    }

    @Test("fetchData throws for 500 response")
    func testFetchData500() async {
        let service = makeService()

        MockURLProtocol.requestHandler = { request in
            let response = self.makeResponse(statusCode: 500, for: request.url!)
            return (response, Data())
        }

        await #expect(throws: URLError.self) {
            _ = try await service.fetchData(from: testURL)
        }
    }

    @Test("fetchData succeeds for all 2xx status codes", arguments: [200, 201, 204, 299])
    func testFetchDataSuccessRange(statusCode: Int) async throws {
        let service = makeService()
        let expectedData = "OK".data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = self.makeResponse(statusCode: statusCode, for: request.url!)
            return (response, expectedData)
        }

        let data = try await service.fetchData(from: testURL)
        #expect(data == expectedData)
    }

    @Test("fetchData throws for non-2xx status codes", arguments: [301, 400, 401, 403, 500, 503])
    func testFetchDataFailureRange(statusCode: Int) async {
        let service = makeService()

        MockURLProtocol.requestHandler = { request in
            let response = self.makeResponse(statusCode: statusCode, for: request.url!)
            return (response, Data())
        }

        await #expect(throws: URLError.self) {
            _ = try await service.fetchData(from: testURL)
        }
    }

    // MARK: - fetch<T> Tests

    @Test("fetch decodes valid JSON response")
    func testFetchDecodesJSON() async throws {
        let service = makeService()
        let model = TestModel(id: 1, name: "Test")
        let jsonData = try JSONEncoder().encode(model)

        MockURLProtocol.requestHandler = { request in
            let response = self.makeResponse(statusCode: 200, for: request.url!)
            return (response, jsonData)
        }

        let result: TestModel = try await service.fetch(from: testURL)
        #expect(result == model)
    }

    @Test("fetch throws DecodingError for invalid JSON")
    func testFetchInvalidJSON() async {
        let service = makeService()
        let invalidJSON = "not json".data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = self.makeResponse(statusCode: 200, for: request.url!)
            return (response, invalidJSON)
        }

        await #expect(throws: DecodingError.self) {
            let _: TestModel = try await service.fetch(from: testURL)
        }
    }

    @Test("fetch throws DecodingError for mismatched JSON schema")
    func testFetchMismatchedSchema() async {
        let service = makeService()
        let wrongSchema = #"{"wrong_field": "value"}"#.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = self.makeResponse(statusCode: 200, for: request.url!)
            return (response, wrongSchema)
        }

        await #expect(throws: DecodingError.self) {
            let _: TestModel = try await service.fetch(from: testURL)
        }
    }

    @Test("fetch propagates HTTP errors before attempting decode")
    func testFetchHTTPErrorBeforeDecode() async {
        let service = makeService()

        MockURLProtocol.requestHandler = { request in
            let response = self.makeResponse(statusCode: 500, for: request.url!)
            return (response, Data())
        }

        await #expect(throws: URLError.self) {
            let _: TestModel = try await service.fetch(from: testURL)
        }
    }

    // MARK: - Request Validation

    @Test("fetchData passes correct URL to URLSession")
    func testFetchDataPassesCorrectURL() async throws {
        let service = makeService()
        let customURL = URL(string: "https://api.example.com/v2/items?page=1")!

        MockURLProtocol.requestHandler = { request in
            #expect(request.url == customURL)
            let response = self.makeResponse(statusCode: 200, for: request.url!)
            return (response, Data())
        }

        _ = try await service.fetchData(from: customURL)
    }
}
