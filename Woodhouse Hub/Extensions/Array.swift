//
//  Array.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 25/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation

extension Array {
	
	func safelyAccess(index: Int) -> Element? {
		if self.hasIndex(index) {
			return self[index]
		} else {
			return nil
		}
	}
	
	func hasIndex(_ index: Int) -> Bool {
		return index >= 0 && index < self.count
	}
	
}