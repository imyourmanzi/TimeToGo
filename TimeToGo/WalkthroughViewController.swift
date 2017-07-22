//
//  WalkthroughViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit
import EventKit
import MapKit

class WalkthroughViewController: UIViewController {
    
    // Interface Builder variables
    @IBOutlet var wtLabel: UILabel!
    @IBOutlet var wtImageView: UIImageView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var getStartedButton: UIButton!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var skipButton: UIButton!
    
    // Current VC variables
    var index: Int = 0
    var wtImageName: String = ""
    var wtDescription: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        
        setupPageElements(for: view.frame.size)
        
    }
    
    private func setupPageElements(for size: CGSize) {
        
        
        if size.width < size.height {
            wtImageView.image = UIImage(named: wtImageName)
        } else {
            wtImageView.image = UIImage(named: wtImageName.appending("Wide"))
        }
    
        wtLabel.text = wtDescription
        
        pageControl.numberOfPages = WalkthroughConstants.NUM_PAGES
        pageControl.currentPage = index
        
        nextButton.isHidden = (index >= WalkthroughConstants.NUM_PAGES - 1)
        skipButton.isHidden = (index >= WalkthroughConstants.NUM_PAGES - 1)
        getStartedButton.isHidden = !(index == WalkthroughConstants.NUM_PAGES - 1)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        setupPageElements(for: size)
        
    }
    
    @IBAction func next(_ sender: UIButton) {
        
        guard let parentVC = parent as? WalkthroughPageViewController else {
            return
        }
        
        parentVC.moveToViewController(at: index + 1)
        
    }
    
    @IBAction func skipToEnd(_ sender: UIButton) {
        
        guard let parentVC = parent as? WalkthroughPageViewController else {
            return
        }
        
        parentVC.moveToViewController(at: WalkthroughConstants.NUM_PAGES - 1)
        
    }
    
    
    @IBAction func getStarted(_ sender: UIButton) {
        
        UserDefaults.standard.set(true, forKey: WalkthroughConstants.NOT_FIRST_LAUNCH_KEY)
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
