import ComposableArchitecture
import XCTest

@testable import MinderaPeople

@MainActor
class DashboardTests: XCTestCase {

    func testUserNotFoundEmptyToken() async {
        let error = MinderaPeopleServiceError.noToken
        let testStore = TestStore(initialState: Dashboard.State(), reducer: Dashboard())
        
        testStore.dependencies.keyChainService.load = { _ in nil }
        testStore.dependencies.minderaPeopleService.user = { _ in throw error }
        testStore.dependencies.logger = .noop
        let task = await testStore.send(.onAppear)
        await testStore.receive(.userNameFetched(.failure(error)))
        XCTAssertEqual(testStore.state.greetingMessage, "Hello")
        await task.cancel()
    }

    func testSuccessfulGreetingMessage() async {
        let user = User.stub()
        let userName = user.name
        let testStore = TestStore(initialState: Dashboard.State(), reducer: Dashboard())
        
        testStore.dependencies.keyChainService.load = { _ in "12345" }
        testStore.dependencies.minderaPeopleService.user = { _ in user }
        
        let task = await testStore.send(.onAppear)
        await testStore.receive(.userNameFetched(.success(userName))) {
            $0.greetingMessage = "Hello, \(userName)"
        }
        XCTAssertEqual(testStore.state.greetingMessage, "Hello, \(userName)")
        await task.cancel()
    }

    func testNotificationsIconNoNotifications() async {
        // TODO: Improve unit test logic once the notifications functionality is in place
        let testStore = TestStore(initialState: Dashboard.State(), reducer: Dashboard())
        
        XCTAssertEqual(testStore.state.notificationsIconName, "bell")
    }
    
    func testNotificationsIconHasNotifications() async {
        // TODO: Improve unit test logic once the notifications functionality is in place
        let testStore = TestStore(initialState: Dashboard.State(hasNotifications: true), reducer: Dashboard())

        XCTAssertEqual(testStore.state.notificationsIconName, "notifications_bell")
    }
}
