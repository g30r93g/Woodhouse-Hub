//
//  NSRegularExpression.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 03/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation

extension NSRegularExpression {
	
	convenience init(_ pattern: String) {
		do {
			try self.init(pattern: pattern)
		} catch {
			preconditionFailure("[NSRegularExpression] Illegal regular expression: \(pattern)")
		}
	}
	
	func matches(_ string: String) -> Bool {
		let range = NSRange(location: 0, length: string.utf16.count)
		return firstMatch(in: string, options: [], range: range) != nil
	}
	
}
