import XCTest
import SwiftyKeychain
import os.log

final class SwiftyKeychainTests: XCTestCase {

	let logger = Logger(subsystem: "com.SwiftyKeychainTests.\(#file)", category: "general")

	func testVerifyKeychainSave() throws {
		let password = "1234"
		let account = "cdw"
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"

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
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"

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
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"

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
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"

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
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"

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
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"

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
			logger.debug("Caught Expected Error.")
		} catch {
			XCTFail("Received unexpected error: \(error)")
		}
	}
	
	func testKeychainDelete() throws {
		let password = "1234"
		let account = "cdw"
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"

		try Keychain.save(password: password,
						  forAccount: account,
						  forService: service)

		let retrievedPassword = try Keychain.retrievePassword(withService: service,
															  account: account)
		XCTAssertEqual(retrievedPassword, password)

		try Keychain.removePassword(withService: service,
									account: account,
									accessGroup: nil)

		do {
			try Keychain.removePassword(withService: service,
										account: account,
										accessGroup: nil)
			XCTFail("This should never fail as the above remove password should fail.")
		} catch Keychain.KeychainServiceError.couldNotFindPassword {
			logger.debug("Encountered expected error.")
		} catch {
			XCTFail("Encountered unexpected error: \(error)")
		}
	}
}
