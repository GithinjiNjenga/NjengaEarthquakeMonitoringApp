//
//  ViewController.swift
//  NjengaEartquakeMonitoringApp
//
//  Created by Gracie on 18/06/2024.
//
import UIKit

class ViewController: UIViewController {

    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "launch image")
        imageView.alpha = 0
        view.addSubview(imageView)

      
        UIView.animate(withDuration: 1.0, animations: {
            self.imageView.alpha = 1
        }) { (finished) in
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.fadeOutImage()
            }
        }
    }

    func fadeOutImage() {
        UIView.animate(withDuration: 1.0, animations: {
            self.imageView.alpha = 0
        }) { (finished) in
            
            self.imageView.removeFromSuperview()
        
            self.transitionToMainInterface()
        }
    }

    func transitionToMainInterface() {

        view.backgroundColor = .white
    }
}


