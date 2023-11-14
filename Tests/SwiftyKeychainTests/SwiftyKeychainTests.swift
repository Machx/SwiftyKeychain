import XCTest
import SwiftyKeychain
import Konkyo
import os.log

final class SwiftyKeychainTests: XCTestCase {

	let shouldSkipUnConvertedTests = true
	//FIXME: update unit tests with unique service for each test so they can run at same time

	let logger = Logger(subsystem: "com.SwiftyKeychainTests.\(#file)", category: "general")

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

	func testVerifyKeychainRetrieveNoAccount() throws {
		let password = "1234"
		let service = "com.SwiftyKeychain.UnitTest"

		try Keychain.save(password: password, forService: service)
		defer {
			try? Keychain.removePassword(withService: service)
		}

		let retrievedPassword = try Keychain.retrievePassword(withService: service)
		XCTAssertEqual(retrievedPassword, password)
	}

	func testVerifyKeychainRetrieveFails() throws {
		let account = UUID().uuidString
		let service = UUID().uuidString

		do {
			let _ = try Keychain.retrievePassword(withService: service,
																  account: account,
																  accessGroup: nil)
			XCTFail("the previous API should have failed")
		} catch Keychain.KeychainServiceError.couldNotFindPassword {
			logger.debug("Caught Expected Error.\(logLocation())")
		} catch {
			XCTFail("Received unexpected error: \(error)")
		}
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
