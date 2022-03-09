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
								account: account)
	}
	
	func testVerifyKeychainRetrieveFails() {
		let account = UUID().uuidString
		let service = UUID().uuidString
		
		let retrieveResult = Keychain.retrievePassword(withService: service,
													   account: account,
													   accessGroup: nil)
		if case let Keychain.KeychainPasswordResult.success(retrievedPassword) = retrieveResult {
			XCTFail("Should not have retrieved a password for an account which should not exist. Password = '\(retrievedPassword)'")
		}
		
		if case let Keychain.KeychainPasswordResult.failure(keychainError) = retrieveResult {
			XCTAssertEqual(keychainError, .couldNotFindPassword)
		} else {
			XCTFail("Somehow the failure was not detected")
		}
	}
	
	func testKeychainDelete() {
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
		
		let retrieveAfterDeleteResult = Keychain.retrievePassword(withService: service, account: account, accessGroup: nil)
		if case let Keychain.KeychainPasswordResult.failure(error) = retrieveAfterDeleteResult {
			if error != Keychain.KeychainServiceError.couldNotFindPassword {
				XCTFail("Should not be able to find new keychain")
			}
		} else {
			XCTFail("Found a password when we shouldn't have found one")
		}
	}

    static var allTests = [
        ("testVerifyKeychainSave", testVerifyKeychainSave),
		("testVerifyKeychainRetrieve", testVerifyKeychainRetrieve),
		("testKeychainDelete", testKeychainDelete),
    ]
}
