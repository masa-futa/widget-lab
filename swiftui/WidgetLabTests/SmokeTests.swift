import Testing

@testable import WidgetLab

struct SmokeTests {
    @Test func appModuleLoads() {
        #expect(Bool(true))
    }
}
