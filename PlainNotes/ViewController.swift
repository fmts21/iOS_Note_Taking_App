//
//  ViewController.swift
//  PlainNotes
//
//  Created by Michael on 2016-03-03.
//  Copyright © 2016 Michael. All rights reserved.
//

import UIKit

protocol segueDelegate {
    func removeCurrentImage(image: UIImage)
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var delegate: segueDelegate? = nil
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = self.image
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "removePic")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removePic() {
        if (delegate != nil) {
            let image = imageView.image
            
            delegate!.removeCurrentImage(image!)
            self.navigationController?.popViewControllerAnimated(true)
        }
 
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
