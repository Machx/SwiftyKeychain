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

		let retrievedPassword = try Keychain.retrievePassword(forService: service,
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

		let retrievedPassword = try Keychain.retrievePassword(forService: service)

		XCTAssertEqual(retrievedPassword, password)
	}

	func testFindAllPasswords() throws {
		let pass1 = "1234"
		let pass2 = "2345"
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"

		try Keychain.save(password: pass1, forAccount: "cdw1", forService: service)
		try Keychain.save(password: pass2, forAccount: "cdw2", forService: service)

		let passwords = try Keychain.retrieveAllPasswords(forService: service)
		defer {
			for (account, _) in passwords {
				try? Keychain.removePassword(withService: service, account: account)
			}
		}

		let cdw1Password = try XCTUnwrap(passwords["cdw1"])
		XCTAssertEqual(cdw1Password, pass1)

		let cdw2Password = try XCTUnwrap(passwords["cdw2"])
		XCTAssertEqual(cdw2Password, pass2)
	}

	func testFindAllPasswordsWithNoAccountPasswords() throws {
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"

		try Keychain.save(password: "pass", forService: service)
		defer {
			try? Keychain.removePassword(withService: service)
		}

		let passwords = try Keychain.retrieveAllPasswords(forService: service)

		XCTAssertEqual(passwords.count, 0)
	}

	func testFindAllPasswordsEmpty() throws {
		let service = "com.SwiftyKeychain.UnitTest-\(UUID().uuidString)"
		let caughtFailure: Bool
		do {
			let _ = try Keychain.retrieveAllPasswords(forService: service)
			caughtFailure = false
		} catch {
			caughtFailure = true
		}
		XCTAssertTrue(caughtFailure)
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

		let retrievedPassword = try Keychain.retrievePassword(forService: service,
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

		let retrievedPassword = try Keychain.retrievePassword(forService: service)
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

		let retrievedPassword = try Keychain.retrievePassword(forService: service, 
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

		let retrievedPassword = try Keychain.retrievePassword(forService: service)
		XCTAssertEqual(retrievedPassword, password)
	}

	func testVerifyKeychainRetrieveFails() throws {
		let account = UUID().uuidString
		let service = UUID().uuidString

		do {
			let _ = try Keychain.retrievePassword(forService: service,
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

		let retrievedPassword = try Keychain.retrievePassword(forService: service,
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
