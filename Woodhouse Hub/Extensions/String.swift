//
//  String.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 17/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit
import SwiftSoup

extension String {
    
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
	
	func extract(from: Int) -> String {
		let index = self.index(self.startIndex, offsetBy: min(from, self.count))
		return String(self[index...])
	}
	
    func extract(from char: Character, occurrence: Int = 0) -> String {
        if occurrence == 0 {
            if self.contains(char) {
                guard let indexOfChar = self.firstIndex(where: {$0 == char}) else { return self }
                
                return self.substring(from: indexOfChar)
            } else {
                return self
            }
        } else {
            return self.extract(from: char, occurrence: occurrence - 1)
        }
    }
    
    func extract(until char: Character, occurrence: Int = 0) -> String {
        if occurrence == 0 {
            if self.contains(char) {
                guard let indexOfChar = self.firstIndex(where: {$0 == char}) else { return self }
                
                return self.substring(to: indexOfChar)
            } else {
                return self
            }
        } else {
            return self.extract(until: char, occurrence: occurrence - 1)
        }
    }
    
    func extractNumbers(limit: Int = 3) -> Int {
		var previousWasNumber: Bool = true
		var number: String = ""
		
		for char in self {
			if char.isNumber {
				number += String(char)
				previousWasNumber = true
			} else if previousWasNumber {
				previousWasNumber = false
			}
			
			if number.count == limit { break }
		}
		
		return Int(number) ?? 0
	}
	
	func base64ToImage() -> UIImage? {
        var img: UIImage = UIImage()
        if (!self.isEmpty) {
            if let decodedData = NSData(base64Encoded: self , options: .ignoreUnknownCharacters) {
                if let decodedimage = UIImage(data: decodedData as Data) {
                    img = (decodedimage as UIImage?)!
                    return img
                }
            }
        }
        return nil
	}
	
	func extractTextBetweenFontTags() -> String {
		let html = try! SwiftSoup.parse(self)
		let text = try! html.getElementsByTag("font").text()
		
		return text
	}
    
    func replaceMonthWithCardinals() -> String {
        var newString = self
        newString = self.replacingOccurrences(of: "January", with: "/01/")
        newString = self.replacingOccurrences(of: "February", with: "/02/")
        newString = self.replacingOccurrences(of: "March", with: "/03/")
        newString = self.replacingOccurrences(of: "April", with: "/04/")
        newString = self.replacingOccurrences(of: "May", with: "/05/")
        newString = self.replacingOccurrences(of: "June", with: "/06/")
        newString = self.replacingOccurrences(of: "July", with: "/07/")
        newString = self.replacingOccurrences(of: "August", with: "/08/")
        newString = self.replacingOccurrences(of: "September", with: "/09/")
        newString = self.replacingOccurrences(of: "October", with: "/10/")
        newString = self.replacingOccurrences(of: "November", with: "/11/")
        newString = self.replacingOccurrences(of: "December", with: "/12/")
        
        newString = newString.replacingOccurrences(of: " /", with: "/")
        newString = newString.replacingOccurrences(of: "/ ", with: "/")
        
        return newString
    }
	
}
