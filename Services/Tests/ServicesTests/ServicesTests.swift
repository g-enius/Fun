import Testing
@testable import FunServices

@Suite("Services Tests")
struct ServicesTests {
    @Test("Services module version")
    func testServicesVersion() async {
        #expect(Services.version == "1.0.0")
    }
}
