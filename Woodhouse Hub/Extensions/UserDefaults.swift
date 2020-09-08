//
//  UserDefaults.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 18/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation
import KeychainAccess

extension UserDefaults {
	
	/// The user defaults suite for Woodhouse Hub
	static let data = UserDefaults(suiteName: "group.com.g30r93g.Woodhouse-Hub")!
	
}

extension Keychain {
    
    /// The keychain suite for Woodhouse Hub
    static let data = Keychain(accessGroup: "group.com.g30r93g.Woodhouse-Hub.Keychain")
    
}
