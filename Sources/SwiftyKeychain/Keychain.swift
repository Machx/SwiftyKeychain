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
	static let shared = Keychain()
	
	/// Errors used in the Keychain Result API's.
	public enum KeychainServiceError: Error {
		case errorEncodingData                 // Error encoding String to Data
		case failureSavingNewPassword          // Error saving password to keychain when calling SecItemAdd()
		case couldNotFindPassword              // Could not find existing password in keychain
		case problemConvertingDataFromKeychain // Error extracting password from SecItemCopyMatching() result
		case serviceNotSpecified               // A Service was not set
		case unhandledError(status: OSStatus)  // Unknown Error with OSStatus Code
	}
	
	func retrievePassword(withService service: String = "", account: String, accessGroup: String? = nil) -> Result<String,KeychainServiceError> {
		var findPasswordQuery = query(withService: service, account: account, accessGroup: accessGroup)
		configure(&findPasswordQuery, limit: .one, returnAttributes: true, returnData: true)
		
		var findPasswordResult: AnyObject?
		let status = withUnsafeMutablePointer(to: &findPasswordResult) {
			SecItemCopyMatching(findPasswordQuery as CFDictionary, UnsafeMutablePointer($0))
		}
		
		guard status != errSecItemNotFound else { return .failure(.couldNotFindPassword) }
		guard status != noErr else { return .failure(.unhandledError(status: status)) }
		
		guard let existingPasswordItem = findPasswordResult as? [String:AnyObject],
			  let passwordData = existingPasswordItem[kSecValueData as String] as? Data,
			  let password = String(data: passwordData, encoding: .utf8) else {
			return .failure(.problemConvertingDataFromKeychain)
		}
		
		return .success(password)
	}
	
	
	/// Saves the password to the keychain with the given additional parameters.
	/// - Parameters:
	///   - password: The Password to be saved.
	///   - account: The Account associated with the Password.
	///   - service: A required Service to use to associate the account/password with.
	///   - accessGroup: An optional accessGroup to use to associate with the password.
	/// - Returns: A result of success (always will return true) if successfully saved, otherwise returns an error.
	func save(password: String, forAccount account: String, service: String, accessGroup: String? = nil) -> Result<Bool,KeychainServiceError> {
		guard let encodedPassword = password.data(using: .utf8) else { return .failure(.errorEncodingData) }
		
		let passwordresult = retrievePassword(withService: service, account: account, accessGroup: accessGroup)
		if case .success(let retrievedPassword) = passwordresult {
			// Previous Password Stored in Keychain...
			guard retrievedPassword != password else { return .success(true) }
			
			var updatingAttributes = [String:AnyObject]()
			updatingAttributes[kSecValueData as String] = encodedPassword as AnyObject
			
			let passwordQuery = query(withService: service, account: account, accessGroup: accessGroup)
			let status = SecItemUpdate(passwordQuery as CFDictionary, updatingAttributes as CFDictionary)
			
			guard status == noErr else { return .failure(.unhandledError(status: status)) }
		} else {
			// No password currently stored in the keychain...
			var newPassword = query(withService: service, account: account, accessGroup: accessGroup)
			newPassword[kSecValueData as String] = encodedPassword as AnyObject?
			
			let status = SecItemAdd(newPassword as CFDictionary, nil)
			
			guard status == noErr else { return .failure(.failureSavingNewPassword) }
		}
		
		return .success(true)
	}
	
	
	/// Creates queries used in the Keychain API's.
	/// - Parameters:
	///   - service: Service accociated with the Password.
	///   - account: Account accociated with the Password.
	///   - accessGroup: Access Group associated with the Password
	/// - Returns: A Dictionary object which can be cast to CFDictionary for use with the Keychain API's.
	private func query(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String:AnyObject] {
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
	
	/// Type used to describe how many rsults should be returned in Keychain Query API's.
	private enum ResultLimit {
		case one // Only 1 result should be returned.
		case all // All results should be returned.
	}
	
	private func configure(_ query: inout [String:AnyObject], limit: ResultLimit = .one, returnAttributes: Bool, returnData: Bool) {
		if case ResultLimit.one = limit {
			query[kSecMatchLimit as String] = kSecMatchLimitOne
		} else {
			query[kSecMatchLimit as String] = kSecMatchLimitAll
		}
		query[kSecReturnAttributes as String] = returnAttributes ? kCFBooleanTrue : kCFBooleanFalse
		query[kSecReturnData as String] = returnData ? kCFBooleanTrue : kCFBooleanFalse
	}
}
