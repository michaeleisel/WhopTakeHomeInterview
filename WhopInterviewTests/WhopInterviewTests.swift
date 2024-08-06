import XCTest
@testable import WhopInterview

final class WhopInterviewTests: XCTestCase {
    func testInfiniteScrollViewModel() throws {
        let viewModel = InfiniteScrollViewModel()
        XCTAssertEqual(viewModel.items.count, 20)
        viewModel.loadMoreItems()
        XCTAssertEqual(viewModel.items.count, 40)
    }
}
