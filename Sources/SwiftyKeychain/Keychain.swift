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

public final class Keychain {
	static let shared = Keychain()
	
	public enum KeychainServiceError: Error {
		case noPassword
		case errorEncodingData
		case failureSavingNewPassword
		case unhandledError(status: OSStatus)
	}
	
	func retrievePassword() -> Result<String,KeychainServiceError> {
		return .success("Hello")
	}
	
	/// Saves the password to the keychain
	/// - Parameter password: The given password
	/// - Returns: Result with success if successful, otherwise returns an error if save failed.
	func save(password: String, forAccount account: String, accessGroup: String? = nil, service: String = "") -> Result<Bool,KeychainServiceError> {
		guard let encodedPassword = password.data(using: .utf8) else { return .failure(.errorEncodingData) }
		
		let passwordresult = retrievePassword()
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
	
	private enum ResultLimit {
		case one
		case all
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
