//
//  WalkthroughPageViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        setupFirstViewController()
        
    }
    
    private func setupFirstViewController() {
        
        guard let firstVC = getViewController(at: 0) else {
            return
        }
        
        setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Navigation
    
    func moveToViewController(at index: Int) {
        
        guard let vc = getViewController(at: index) else {
            return
        }
        
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        
    }
    
    func getViewController(at index: Int) -> WalkthroughViewController? {
        
        if index < 0 || index >= WalkthroughConstants.NUM_PAGES {
            return nil
        }
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: IDs.VC_WALKTHROUGH) as? WalkthroughViewController else {
            return nil
        }
        
        vc.index = index
        vc.wtImageName = WalkthroughConstants.WT_IMG_NAMES[index]
        vc.wtDescription = WalkthroughConstants.WT_DESCRIPTIONS[index]
        
        return vc
        
    }

}


// MARK: - Page view data source

extension WalkthroughPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? WalkthroughViewController else {
            return nil
        }
        
        return getViewController(at: vc.index - 1)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? WalkthroughViewController else {
            return nil
        }
        
        return getViewController(at: vc.index + 1)
        
    }
    
}
