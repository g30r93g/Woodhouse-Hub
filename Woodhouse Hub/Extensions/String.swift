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
	
	func extract(from: Int) -> String {
		let index = self.index(self.startIndex, offsetBy: min(from, self.count))
		return String(self[index...])
	}
	
	func extract(from char: Character) -> String {
		if self.contains(char) {
			guard let indexOfChar = self.firstIndex(where: {$0 == char}) else { return self }
			
			return self.substring(from: indexOfChar)
		} else {
			return self
		}
	}
	
	func extract(until char: Character) -> String {
		if self.contains(char) {
			guard let indexOfChar = self.firstIndex(where: {$0 == char}) else { return self }
			
			return self.substring(to: indexOfChar)
		} else {
			return self
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
	
}
