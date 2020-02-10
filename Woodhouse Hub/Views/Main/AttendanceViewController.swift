//
//  AttendanceViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 10/02/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class AttendanceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
	
	// MARK: Methods
	
	// MARK: IBActions
	@IBAction func dismissTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}

}

extension AttendanceViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
	
}
