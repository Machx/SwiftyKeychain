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
		case unhandledError(status: OSStatus)
	}
	
	func retrievePassword() -> Result<String,KeychainServiceError> {
		return .success("Hello")
	}
	
	/// Saves the password to the keychain
	/// - Parameter password: The given password
	/// - Returns: Result with success if successful, otherwise returns an error if save failed.
	func save(password: String) -> Result<Bool,KeychainServiceError> {
		guard let encodedPassword = password.data(using: .utf8) else { return .failure(.errorEncodingData) }
		
		do {
			
		}
		
		return .success(true)
	}
	
	private static func query(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String:AnyObject] {
		var query = [String: AnyObject]()
		query[kSecClass as String] = kSecClassGenericPassword
		query[kSecAttrService as String] = service as AnyObject
		
		if let account = account {
			query[kSecAttrAccount as String] = account as AnyObject
		}
		if let accessGroup = accessGroup {
			query[kSecAttrAccessGroup as String] = accessGroup as AnyObject
		}
		
		return query
	}
	}
}
