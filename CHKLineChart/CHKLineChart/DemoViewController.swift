//
//  ViewController.swift
//  CHKLineChart
//
//  Created by Chance on 16/8/31.
//  Copyright © 2016年 Chance. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    
    @IBOutlet var buttonShow: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleShowKLineView(sender: AnyObject?) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChartDemoViewController") as! ChartDemoViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func handleShowCustomKLineView(sender: AnyObject?) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomStyleViewController") as! CustomStyleViewController
        self.present(vc, animated: true, completion: nil)
    }
   
    @IBAction func handleShowStrangeKLineView(sender: AnyObject?) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChartCustomSectionViewController") as! ChartCustomSectionViewController
        self.present(vc, animated: true, completion: nil)
    }
}

