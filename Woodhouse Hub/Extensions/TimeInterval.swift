//
//  TimeInterval.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 25/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation

extension TimeInterval{

	func stringFromTimeInterval() -> String {

		let time = NSInteger(self)

		let minutes = (time / 60) % 60
		let hours = time / 3600

		if minutes == 0 {
			return "\(hours) hours"
		} else {
			return "\(hours) hours, \(minutes) minutes"
		}
	}
}
