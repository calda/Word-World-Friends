//
//  FriendsViewController.swift
//  WordWorld
//
//  Created by Cal on 6/18/15.
//  Copyright © 2015 Hear a Tale. All rights reserved.
//

import Foundation
import UIKit

let WWFriendsSettingsPaths = ["you", "friend1", "friend2", "friend3", "friend4"]
var WWFriendsSize: CGSize!
let WWUpdateFriendsNotification = "com.hearatale.wordworld.update-friends-notification"

class FriendsViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(FriendsViewController.updateFriends), name: NSNotification.Name(rawValue: WWUpdateFriendsNotification), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "body", for: indexPath) as! FriendCell
        cell.decorate(indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = height * 0.53
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bodyEditController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "bodyEdit") as! BodyViewController
        bodyEditController.prepareEditor(color: friendColorForIndexPath(indexPath), friend: WWFriendsSettingsPaths[indexPath.item])
        self.present(bodyEditController, animated: true, completion: nil)
    }
    
    @objc func updateFriends() {
        collectionView.reloadData()
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

class FriendCell : UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var colorBackground: UIView!
    @IBOutlet weak var text: UILabel!
    
    func decorate(_ index: IndexPath) {
        
        WWFriendsSize = CGSize(width: image.frame.width * UIScreen.main.scale, height: image.frame.height * UIScreen.main.scale)
        
        let title = (index.item == 0 ? "You" : "Friend \(index.item)")
        text.text = title
        
        let color = friendColorForIndexPath(index)
        colorBackground.backgroundColor = color
        
        //load friend image if settings path exists
        let userData = UserDefaults.standard
        if userData.value(forKey: WWFriendsSettingsPaths[index.item]) != nil {
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsPath = paths[0]
            let savePath = (documentsPath as NSString).appendingPathComponent("\(WWFriendsSettingsPaths[index.item]).png")
            
            let data = try? Data(contentsOf: URL(fileURLWithPath: savePath))
            if let data = data {
                let image = UIImage(data: data)
                self.image.image = image
            }
            
        }
        
        else {
            print("\(index.item) to blank")
            self.image.image = UIImage(named: "Body Feature/Body-Feature-body.png")
        }
        
    }
    
}

//pragma MARK: - UIColor.. stuff..

extension UIColor {
    
    func darken() -> UIColor {
        var hue: CGFloat = 0.0
        var sat: CGFloat = 0.0
        var bright: CGFloat = 0.0
        self.getHue(&hue, saturation: &sat, brightness: &bright, alpha: nil)
        
        return UIColor(hue: hue, saturation: sat - 0.1, brightness: bright - 0.1, alpha: 1.0)
    }
    
    func lighten() -> UIColor {
        var hue: CGFloat = 0.0
        var sat: CGFloat = 0.0
        var bright: CGFloat = 0.0
        self.getHue(&hue, saturation: &sat, brightness: &bright, alpha: nil)
        
        return UIColor(hue: hue, saturation: sat + 0.1, brightness: bright + 0.1, alpha: 1.0)
    }
    
}

func friendColorForIndexPath(_ indexPath: IndexPath) -> UIColor {
    let index = indexPath.item
    
    var hue = CGFloat(202.0 / 360.0)
    hue += 0.11 * CGFloat(index)
    if hue > 1.0 { hue -= 1.0 }
    
    return UIColor(hue: hue, saturation: 0.52, brightness: 0.84, alpha: 1.0)
}
