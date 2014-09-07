//
//  DetailViewController.swift
//  Example
//
//  Created by Shintaro Kaneko on 9/8/14.
//  Copyright (c) 2014 kaneshinth.com. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
                            
    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var eventItem: Event? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let event = self.eventItem as Event? {
            if let label = self.detailDescriptionLabel {
                label.text = event.timeStamp.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

}

