import XCTest
import SwiftyKeychain

final class SwiftyKeychainTests: XCTestCase {

	let shouldSkipUnConvertedTests = true

	func testVerifyKeychainSave() throws {
		let password = "1234"
		let account = "cdw"
		let service = "com.SwiftyKeychain.UnitTest"

		try Keychain.save(password: password,
						  forAccount: account,
						  forService: service)
		defer {
			try? Keychain.removePassword(withService: service,
										account: account)
		}

		let retrievedPassword = try Keychain.retrievePassword(withService: service,
															  account: account)

		XCTAssertEqual(retrievedPassword, password)
	}

	func testVerifyKeychainSaveNoAccount() throws {
		let password = "1234"
		let service = "com.SwiftyKeychain.UnitTest"

		try Keychain.save(password: password,
						  forService: service)
		defer {
			try? Keychain.removePassword(withService: service)
		}

		let retrievedPassword = try Keychain.retrievePassword(withService: service)

		XCTAssertEqual(retrievedPassword, password)
	}

	func testPasswordUpdate() throws {
		let password = "1234"
		let account = "cdw"
		let service = "com.SwiftyKeychain.UnitTest"

		try Keychain.save(password: password,
					  forAccount: account,
					  forService: service)
		defer {
			try? Keychain.removePassword(withService: service,
										 account: account)
		}

		try Keychain.save(password: "4321",
						  forAccount: account,
						  forService: service)

		let retrievedPassword = try Keychain.retrievePassword(withService: service,
															  account: account,
															  accessGroup: nil)

		XCTAssertEqual(retrievedPassword, "4321")
	}

	func testPasswordUpdateNoAccount() throws {
		let password = "1234"
		let service = "com.SwiftyKeychain.UnitTest"

		try Keychain.save(password: password,
						  forService: service)
		defer {
			try? Keychain.removePassword(withService: service)
		}

		try Keychain.save(password: "4321",
						  forService: service)

		let retrievedPassword = try Keychain.retrievePassword(withService: service)
		XCTAssertEqual(retrievedPassword, "4321")
}

	func testVerifyKeychainRetrieve() throws {
		try XCTSkipIf(shouldSkipUnConvertedTests)

//		let password = "1234"
//		let account = "cdw"
//		let service = "com.SwiftyKeychain.UnitTest"
//		
//		let result = Keychain.save(password: password,
//								   forAccount: account,
//								   forService: service)
//		if case let Keychain.KeychainResult.failure(error) = result {
//			XCTFail("Failed with error \(error)")
//			return
//		}
//		
//		let retrieveResult = Keychain.retrievePassword(withService: service,
//													   account: account,
//													   accessGroup: nil)
//		if case let Keychain.KeychainPasswordResult.failure(error) = retrieveResult {
//			XCTFail("Failed with error \(error)")
//		} else if case let Keychain.KeychainPasswordResult.success(retrievedPassword) = retrieveResult {
//			XCTAssertEqual(retrievedPassword, password)
//		}
//		
//		Keychain.removePassword(withService: service,
//								account: account)
	}

	func testVerifyKeychainRetrieveNoAccount() throws {
		try XCTSkipIf(shouldSkipUnConvertedTests)

//		let password = "1234"
//		let service = "com.SwiftyKeychain.UnitTest"
//
//		let result = Keychain.save(password: password,
//								   forService: service)
//		if case let Keychain.KeychainResult.failure(error) = result {
//			XCTFail("Failed with error \(error)")
//			return
//		}
//
//		let retrieveResult = Keychain.retrievePassword(withService: service,
//													   accessGroup: nil)
//		if case let Keychain.KeychainPasswordResult.failure(error) = retrieveResult {
//			XCTFail("Failed with error \(error)")
//		} else if case let Keychain.KeychainPasswordResult.success(retrievedPassword) = retrieveResult {
//			XCTAssertEqual(retrievedPassword, password)
//		}
//
//		Keychain.removePassword(withService: service)
	}

	func testVerifyKeychainRetrieveFails() throws {
		try XCTSkipIf(shouldSkipUnConvertedTests)

//		let account = UUID().uuidString
//		let service = UUID().uuidString
//		
//		let retrieveResult = Keychain.retrievePassword(withService: service,
//													   account: account,
//													   accessGroup: nil)
//		if case let Keychain.KeychainPasswordResult.success(retrievedPassword) = retrieveResult {
//			XCTFail("Should not have retrieved a password for an account which should not exist. Password = '\(retrievedPassword)'")
//		}
//		
//		if case let Keychain.KeychainPasswordResult.failure(keychainError) = retrieveResult {
//			XCTAssertEqual(keychainError, .couldNotFindPassword)
//		} else {
//			XCTFail("Somehow the failure was not detected")
//		}
	}
	
	func testKeychainDelete() throws {
		try XCTSkipIf(shouldSkipUnConvertedTests)

//		let password = "1234"
//		let account = "cdw"
//		let service = "com.SwiftyKeychain.UnitTest"
//		
//		let result = Keychain.save(password: password,
//								   forAccount: account,
//								   forService: service)
//		if case let Keychain.KeychainResult.failure(error) = result {
//			XCTFail("Failed with error \(error)")
//			return
//		}
//		
//		let retrieveResult = Keychain.retrievePassword(withService: service,
//													   account: account,
//													   accessGroup: nil)
//		if case let Keychain.KeychainPasswordResult.failure(error) = retrieveResult {
//			XCTFail("Failed with error \(error)")
//		} else if case let Keychain.KeychainPasswordResult.success(retrievedPassword) = retrieveResult {
//			XCTAssertEqual(retrievedPassword, password)
//		}
//		
//		Keychain.removePassword(withService: service,
//								account: account,
//								accessGroup: nil)
//		
//		let retrieveAfterDeleteResult = Keychain.retrievePassword(withService: service, account: account, accessGroup: nil)
//		if case let Keychain.KeychainPasswordResult.failure(error) = retrieveAfterDeleteResult {
//			if error != Keychain.KeychainServiceError.couldNotFindPassword {
//				XCTFail("Should not be able to find new keychain")
//			}
//		} else {
//			XCTFail("Found a password when we shouldn't have found one")
//		}
	}
}
