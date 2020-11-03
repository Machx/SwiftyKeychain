import XCTest
@testable import SwiftyKeychain

final class SwiftyKeychainTests: XCTestCase {
    
	func testVerifyKeychainSave() {
		let password = "1234"
		let account = "cdw"
		let service = "com.SwiftyKeychain.UnitTest"
		let result = Keychain.save(password: password,
								   forAccount: account,
								   service: service)
		
		if case let Keychain.KeychainResult.failure(error) = result {
			XCTFail("Failed to save password to keychain with error = \(error)")
		}
		
		Keychain.removePassword(withService: service,
								account: account,
								accessGroup: nil)
	}

    static var allTests = [
        ("testExample", testExample),
    ]
}
