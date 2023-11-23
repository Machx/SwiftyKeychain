/// Copyright 2020 Colin Wheeler
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///	http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import Foundation
import Security

public final class Keychain {
	
	//MARK: - Public API

	/// Errors used in the Keychain Result API's.
	public enum KeychainServiceError: Error, Equatable {
		case errorEncodingData                 // Error encoding String to Data
		case failureSavingNewPassword          // Error saving password to keychain when calling SecItemAdd()
		case couldNotFindPassword              // Could not find existing password in keychain
		case problemConvertingDataFromKeychain // Error extracting password from SecItemCopyMatching() result
		case serviceNotSpecified               // A Service was not set
		case unhandledError(status: OSStatus)  // Unknown Error with OSStatus Code
	}
	
	/// Retrieves the password from the keychain with the given parameters if the password is found.
	/// - Parameters:
	///   - service: A required Service to use to associate the account/password with.
	///   - account: The Account for the given password.
	///   - accessGroup: Optional Access group associated with the password.
	/// - Returns: A Result with the password, or an error describing the problem encountered retrieving it.
	@discardableResult
	public class func retrievePassword(forService service: String,
									   account: String? = nil,
									   accessGroup: String? = nil) throws -> String {
		guard !service.isEmpty else {
			throw KeychainServiceError.serviceNotSpecified
		}
		var findPasswordQuery = query(withService: service, account: account, accessGroup: accessGroup)
		configure(&findPasswordQuery, limit: .one, returnAttributes: true, returnData: true)
		
		var findPasswordResult: AnyObject?
		let status = withUnsafeMutablePointer(to: &findPasswordResult) {
			SecItemCopyMatching(findPasswordQuery as CFDictionary, UnsafeMutablePointer($0))
		}
		
		guard status != errSecItemNotFound else {
			throw KeychainServiceError.couldNotFindPassword
		}
		guard status == noErr else {
			throw KeychainServiceError.unhandledError(status: status)
		}
		
		guard let existingPasswordItem = findPasswordResult as? [String:AnyObject],
			  let passwordData = existingPasswordItem[kSecValueData as String] as? Data,
			  let password = String(data: passwordData, encoding: .utf8) else {
			throw KeychainServiceError.problemConvertingDataFromKeychain
		}
		
		return password
	}

	public class func retrieveAllPasswords(forService service: String,
										   accessGroup: String? = nil) throws -> [String:String] {
		guard !service.isEmpty else {
			throw KeychainServiceError.serviceNotSpecified
		}
		var findPasswordQuery = query(withService: service, account: nil, accessGroup: accessGroup)
		configure(&findPasswordQuery, limit: .all, returnAttributes: true, returnData: false)

		var items: CFTypeRef?
		let status = withUnsafeMutablePointer(to: &items) {
			SecItemCopyMatching(findPasswordQuery as CFDictionary, UnsafeMutablePointer($0))
		}

		guard status == noErr,
			  let entries = items as? [[String : Any]] else {
			throw KeychainServiceError.unhandledError(status: status)
		}

		var results = [String]()
		for entry in entries {
			if let account = entry[kSecAttrAccount as String],
			   let data = entry[kSecValueData as String] as? Data,
			   let value = String(data: data, encoding: .utf8) {
				results.append(value)
			}
		}
	}

	/// Saves the password to the keychain with the given additional parameters.
	/// - Parameters:
	///   - password: The Password to be saved.
	///   - account: The Account associated with the Password.
	///   - service: A required Service to use to associate the account/password with.
	///   - accessGroup: An optional accessGroup to use to associate with the password.
	/// - Returns: A result of success (always will return true) if successfully saved, otherwise returns an error.
	public class func save(password: String,
						   forAccount account: String? = nil,
						   forService service: String,
						   accessGroup: String? = nil) throws {
		guard !service.isEmpty else { throw KeychainServiceError.serviceNotSpecified }
		guard let encodedPassword = password.data(using: .utf8) else { throw KeychainServiceError.errorEncodingData }

		if let retrievedPassword = try? retrievePassword(forService: service, account: account, accessGroup: accessGroup) {
			// Previous Password Stored in Keychain...
			guard retrievedPassword != password else { return }

			var updatingAttributes = [String:AnyObject]()
			updatingAttributes[kSecValueData as String] = encodedPassword as AnyObject

			let passwordQuery = query(withService: service, account: account, accessGroup: accessGroup)
			let status = SecItemUpdate(passwordQuery as CFDictionary, updatingAttributes as CFDictionary)

			guard status == noErr else {
				throw KeychainServiceError.unhandledError(status: status)
			}
		} else {
			// No password currently stored in the keychain...
			var newPassword = query(withService: service, account: account, accessGroup: accessGroup)
			newPassword[kSecValueData as String] = encodedPassword as AnyObject?

			let status = SecItemAdd(newPassword as CFDictionary, nil)

			guard status == noErr else {
				throw KeychainServiceError.failureSavingNewPassword
			}
		}
	}
	
	/// Removes a given password from the Keychain
	/// - Parameters:
	///   - service: A Service that the account/password as associated with.
	///   - account: The Account associated with the Password.
	///   - accessGroup: Optional Access group associated with the password.
	/// - Returns: A Bool value of true on success, otherwise returns a KeychainServiceError describing the issue encountered.
	public class func removePassword(withService service: String,
									 account: String? = nil,
									 accessGroup: String? = nil) throws {
		guard !service.isEmpty else { throw KeychainServiceError.serviceNotSpecified }
		let deleteQuery = query(withService: service, 
								account: account,
								accessGroup: accessGroup)
		let status = SecItemDelete(deleteQuery as CFDictionary)
		
		guard status != errSecItemNotFound else {
			throw KeychainServiceError.couldNotFindPassword
		}
		guard status == noErr else {
			throw KeychainServiceError.unhandledError(status: status)
		}
	}
	
	//MARK: - Private Support Functions
	
	
	/// Creates queries used in the Keychain API's.
	/// - Parameters:
	///   - service: Service associated with the Password.
	///   - account: Account associated with the Password.
	///   - accessGroup: Access Group associated with the Password
	/// - Returns: A Dictionary object which can be cast to CFDictionary for use with the Keychain API's.
	private class func query(withService service: String,
							 account: String? = nil,
							 accessGroup: String? = nil) -> [String:AnyObject] {
		var query = [String: AnyObject]()
		query[kSecClass as String] = kSecClassGenericPassword
		query[kSecAttrService as String] = service as AnyObject
		configure(&query, limit: .one, returnAttributes: true, returnData: false)
		
		if let account = account {
			query[kSecAttrAccount as String] = account as AnyObject
		}
		if let accessGroup = accessGroup {
			query[kSecAttrAccessGroup as String] = accessGroup as AnyObject
		}
		
		return query
	}
	
	/// Type used to describe how many results should be returned in Keychain Query API's.
	private enum ResultLimit {
		case one // Only 1 result should be returned.
		case all // All results should be returned.
	}
	
	private class func configure(_ query: inout [String:AnyObject],
								 limit: ResultLimit = .one,
								 returnAttributes: Bool,
								 returnData: Bool) {
		if case ResultLimit.one = limit {
			query[kSecMatchLimit as String] = kSecMatchLimitOne
		} else {
			query[kSecMatchLimit as String] = kSecMatchLimitAll
		}
		query[kSecReturnAttributes as String] = returnAttributes ? kCFBooleanTrue : kCFBooleanFalse
		query[kSecReturnData as String] = returnData ? kCFBooleanTrue : kCFBooleanFalse
	}
}
