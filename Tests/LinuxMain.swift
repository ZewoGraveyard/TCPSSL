#if os(Linux)

import XCTest
@testable import TCPSSLTestSuite

XCTMain([
    testCase(TCPSSLTests.allTests)
])

#endif
