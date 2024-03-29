# SwiftyKeychain

Swifty keychain is a simple Swift API wrapper around Apples Keychain API's. It aims to provide a simple, and yet flexible Keychain wrapper with no additional dependencies. 

## Usage

```swift
let password = "1234"
let service = "MyApp"

//Saving a Password
try Keychain.save(password: password,
				forService: service)

// Retrieving a password
let retrievedPassword = try Keychain.retrievePassword(withService: service)

// Deleting a password
try Keychain.removePassword(withService: service)
```

## License
SwiftyKeychain is licensed under the Apache 2 license.

```
Copyright 2020 Colin Wheeler

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
