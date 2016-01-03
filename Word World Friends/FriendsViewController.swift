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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFriends", name: WWUpdateFriendsNotification, object: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("body", forIndexPath: indexPath) as! FriendCell
        cell.decorate(indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = height * 0.53
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let bodyEditController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("bodyEdit") as! BodyViewController
        bodyEditController.prepareEditor(color: friendColorForIndexPath(indexPath), friend: WWFriendsSettingsPaths[indexPath.item])
        self.presentViewController(bodyEditController, animated: true, completion: nil)
    }
    
    func updateFriends() {
        collectionView.reloadData()
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class FriendCell : UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var colorBackground: UIView!
    @IBOutlet weak var text: UILabel!
    
    func decorate(index: NSIndexPath) {
        
        WWFriendsSize = CGSizeMake(image.frame.width * UIScreen.mainScreen().scale, image.frame.height * UIScreen.mainScreen().scale)
        
        let title = (index.item == 0 ? "You" : "Friend \(index.item)")
        text.text = title
        
        let color = friendColorForIndexPath(index)
        colorBackground.backgroundColor = color
        
        //load friend image if settings path exists
        let userData = NSUserDefaults.standardUserDefaults()
        if userData.valueForKey(WWFriendsSettingsPaths[index.item]) != nil {
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsPath = paths[0]
            let savePath = (documentsPath as NSString).stringByAppendingPathComponent("\(WWFriendsSettingsPaths[index.item]).png")
            
            let data = NSData(contentsOfFile: savePath)
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

func friendColorForIndexPath(indexPath: NSIndexPath) -> UIColor {
    let index = indexPath.item
    
    var hue = CGFloat(202.0 / 360.0)
    hue += 0.11 * CGFloat(index)
    if hue > 1.0 { hue -= 1.0 }
    
    return UIColor(hue: hue, saturation: 0.52, brightness: 0.84, alpha: 1.0)
}