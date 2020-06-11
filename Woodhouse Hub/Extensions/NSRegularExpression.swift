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
	
	func matches(_ text: String) -> Bool {
		let range = NSRange(location: 0, length: text.utf16.count)
		return firstMatch(in: text, options: [], range: range) != nil
	}
    
    func allMatches(for text: String) -> [String] {
        let range = NSRange(location: 0, length: text.utf16.count)
        let results = matches(in: text, options: [], range: range)
        
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    }
	
}
