//
//  UCASPredictionsViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 19/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class UCASPredictionsViewController: UIViewController {

	// MARK: IBOutlets
	@IBOutlet weak var predictionsTable: UITableView!
	
	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
	
	// MARK: IBActions
	@IBAction func dismissTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

extension UCASPredictionsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let ucasPredictions = Student.current.studentProfile?.ucasPredictions else { return 0 }
		return ucasPredictions.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "UCAS Prediction", for: indexPath) as! UCASPredictionCell
		guard let ucasPredictions = Student.current.studentProfile?.ucasPredictions else { return cell }
		let data = ucasPredictions[indexPath.row]
		
		cell.setupCell(from: data, index: indexPath.row)
		
		return cell
	}
	
}
