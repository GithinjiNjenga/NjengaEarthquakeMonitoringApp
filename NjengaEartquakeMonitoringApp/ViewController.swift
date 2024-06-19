//
//  ViewController.swift
//  NjengaEartquakeMonitoringApp
//
//  Created by Gracie on 18/06/2024.
//

import UIKit

class ViewsController: UIViewController {

    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50) // Start with a small size
        imageView.center = view.center
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "launch image") // Replace with your image name
        imageView.alpha = 0 // Start with image view hidden
        view.addSubview(imageView)

        // Animate the image view scaling and fading in
        UIView.animate(withDuration: 1.0, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0) // Scale up to 2 times
            self.imageView.alpha = 1 // Fade in
        }) { (finished) in
            // Delay for 4 seconds before starting the explosion animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.explodeImage()
            }
        }
    }

    func explodeImage() {
        // Scale up and fade out animation
        UIView.animate(withDuration: 0.5, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 5.0, y: 5.0) // Scale up to 5 times
            self.imageView.alpha = 0 // Fade out
        }) { (finished) in
            // Remove imageView from superview or reset as needed
            self.imageView.removeFromSuperview()
        }
    }
}
