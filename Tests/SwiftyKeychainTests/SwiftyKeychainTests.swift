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
	
	func testVerifyKeychainRetrieve() {
		let password = "1234"
		let account = "cdw"
		let service = "com.SwiftyKeychain.UnitTest"
		
		let result = Keychain.save(password: password,
								   forAccount: account,
								   service: service)
		if case let Keychain.KeychainResult.failure(error) = result {
			XCTFail("Failed with error \(error)")
			return
		}
		
		let retrieveResult = Keychain.retrievePassword(withService: service,
													   account: account,
													   accessGroup: nil)
		if case let Keychain.KeychainPasswordResult.failure(error) = retrieveResult {
			XCTFail("Failed with error \(error)")
		} else if case let Keychain.KeychainPasswordResult.success(retrievedPassword) = retrieveResult {
			XCTAssertEqual(retrievedPassword, password)
		}
		
		Keychain.removePassword(withService: service,
								account: account,
								accessGroup: nil)
	}

    static var allTests = [
        ("testExample", testExample),
    ]
}
