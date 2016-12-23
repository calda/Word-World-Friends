//
//  BodyViewController.swift
//  WordWorld
//
//  Created by Cal on 6/3/15.
//  Copyright (c) 2015 Hear a Tale. All rights reserved.
//

import Foundation
import UIKit
import Photos

let WWCloseClassCollectionNotification = "com.hearatale.wordworld.closeclass"
let WWBodyBackgroundThread = DispatchQueue(label: "WWBodyBackground", attributes: [])

class BodyViewController : UIViewController {
    
    @IBOutlet weak var body: UIImageView!
    @IBOutlet weak var skinTone: UIImageView!
    @IBOutlet weak var socks: UIImageView!
    @IBOutlet weak var shoes: UIImageView!
    @IBOutlet weak var pants: UIImageView!
    @IBOutlet weak var belt: UIImageView!
    @IBOutlet weak var shirt: UIImageView!
    @IBOutlet weak var bowtie: UIImageView!
    @IBOutlet weak var mouth: UIImageView!
    @IBOutlet weak var nose: UIImageView!
    @IBOutlet weak var eyes: UIImageView!
    @IBOutlet weak var hair: UIImageView!
    @IBOutlet weak var glasses: UIImageView!
    @IBOutlet weak var wrist: UIImageView!
    @IBOutlet weak var hold: UIImageView!
    
    var imageMap: [String : UIImageView]!
    var outfitMap: [NSString : NSString] = ["bodyShape" : "Body-Feature-body.png"]
    var allFeatures: [BodyFeature] = []
    let classOrder = ["bodyShape", "body", "hair", "eyes", "nose", "mouth", "glasses", "shirt", "pants", "socks", "shoes", "bowtie", "belt", "wrist", "hold"]
    
    var currentSkinToneFeature: BodyFeature?
    let outlineHolding = "Body-Feature-body2"
    let outlineStraight = "Body-Feature-body"
    
    @IBOutlet weak var categoryCollection: UICollectionView!
    var categoryDelegate: CategoryCollectionDelegate?
    
    @IBOutlet weak var classCollection: UICollectionView!
    @IBOutlet weak var classConstraint: NSLayoutConstraint!
    var classDelegate: ClassCollectionDelegate?
    @IBOutlet weak var classTitle: UILabel!
    
    //pragma MARK: - Set Up for customizing user choice of friend
    
    @IBOutlet weak var classHeaderBackground: UIView!
    @IBOutlet weak var colorBack: UIButton!
    @IBOutlet weak var colorDice: UIButton!
    @IBOutlet weak var colorDownload: UIButton!
    @IBOutlet weak var colorReset: UIImageView!
    
    var themedColor: UIColor!
    var currentFriend: String!
    
    func prepareEditor(color: UIColor, friend: String) {
        self.themedColor = color
        self.currentFriend = friend
        
        //load existing outfit
        let userData = UserDefaults.standard
        if let savedOutfit = userData.value(forKey: currentFriend) as? [NSString : NSString] {
            outfitMap = savedOutfit
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageMap = [
            "bodyShape" : body,
            "body" : skinTone,
            "socks" : socks,
            "shoes" : shoes,
            "pants" : pants,
            "belt" : belt,
            "shirt" : shirt,
            "bowtie" : bowtie,
            "mouth" : mouth,
            "nose" : nose,
            "eyes" : eyes,
            "hair" : hair,
            "glasses" : glasses,
            "wrist" : wrist,
            "hold" : hold
        ]
        
        //load data from CSV
        let csvPath = Bundle.main.path(forResource: "Body Feature/body feature database", ofType: "csv")!
        let csvString = try! String(contentsOfFile: csvPath, encoding: String.Encoding.utf8)
        let csv = csvString.components(separatedBy: "\n")
        
        //process csv
        for line in csv {
            let cells = line.components(separatedBy: ",")
            if cells.count != 3 {
                continue
            }
            
            let feature = BodyFeature(csvEntry: line)
            allFeatures.append(feature)
        }
        
        //set up collection views
        //category collection
        categoryDelegate = CategoryCollectionDelegate(controller: self)
        categoryCollection.delegate = categoryDelegate!
        categoryCollection.dataSource = categoryDelegate!
        categoryCollection.reloadData()
        
        //class collection
        classDelegate = ClassCollectionDelegate(controller: self)
        classCollection.delegate = classDelegate
        classCollection.dataSource = classDelegate
        classConstraint.constant = (classCollection.frame.width + 100)
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(BodyViewController.closeClassCollection), name: NSNotification.Name(rawValue: WWCloseClassCollectionNotification), object: nil)
        
        //tint with theme color
        classHeaderBackground.backgroundColor = themedColor
        
        //tint buttons
        let buttonsToTint = [colorBack, colorDice, colorDownload]
        for button in buttonsToTint {
            let tintable = button?.imageView!.image!.withRenderingMode(.alwaysTemplate)
            button?.setImage(tintable, for: UIControlState())
            button?.imageView!.tintColor = themedColor.darken()
        }
        
        //tint images
        let imagesToTint = [colorReset]
        for imageView in imagesToTint {
            let tintable = imageView?.image?.withRenderingMode(.alwaysTemplate)
            imageView?.image = tintable
            imageView?.tintColor = themedColor.darken().darken()
        }
        
        
        //update outfit to saved outfit
        for (className, imageName) in outfitMap {
            imageMap[className as String]?.image = UIImage(named: "Body Feature/\(imageName)")
        }
        
    }
    
    @IBAction func close(_ sender: AnyObject) {
        
        func dismissThis() {
            self.dismiss(animated: true, completion: {
                
                //set all imageViews to nil
                for (_, imageView) in self.imageMap {
                    imageView.image = nil
                }
                
            })
        }
        
        
        let userData = UserDefaults.standard
        
        //check if any changes have been made
        let previousOutfit = userData.value(forKey: currentFriend)
        var mustSaveChanges = true
        if let previousOutfit = previousOutfit as? [NSString : NSString] {
            mustSaveChanges = previousOutfit != outfitMap
        }
        
        //save outfit data if necessary
        if mustSaveChanges {
            //present saving alert
            let saveAlert = UIAlertController(title: "Saving your Friend", message: "This will only take a second...", preferredStyle: UIAlertControllerStyle.alert)
            self.present(saveAlert, animated: true, completion: {
                
                //finish saving
                userData.setValue(self.outfitMap, forKey: self.currentFriend)
                
                let bodyImage = self.createImageOfBody(resize: true)
                let imageData = UIImagePNGRepresentation(bodyImage)
                
                //write to documents folder
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let documentsPath = paths[0]
                let savePath = (documentsPath as NSString).appendingPathComponent("\(self.currentFriend).png")
                try? imageData?.write(to: URL(fileURLWithPath: savePath), options: [.atomic])
                
                //send notification to Friends view
                NotificationCenter.default.post(name: Notification.Name(rawValue: WWUpdateFriendsNotification), object: nil, userInfo: nil)
                
                self.dismiss(animated: true, completion: {
                    dismissThis()
                })
                
            })
        }
        
        else {
            dismissThis()
        }
        
        
        
    }
    
    
    //pragma MARK: - Managing Body Figure
    
    func setImageInView(_ className: String, toFeature feature: BodyFeature?) {
        if let imageView = imageMap![className] {
            //deinit previous
            imageView.image = nil
            
            //set new
            imageView.image = feature?.getImage(cropped: false)
            
            //save to outfit map
            if let feature = feature {
                outfitMap.updateValue(feature.fileName as NSString, forKey: className as NSString)
            } else {
                outfitMap.removeValue(forKey: className as NSString)
            }
            
            //ensure correct body stance
            if className == "body" || className == "hold" {
                if className == "body" { currentSkinToneFeature = feature }
                
                let isHolding = hold.image != nil
                if isHolding {
                    //outline
                    body.image = UIImage(named: "Body Feature/" + outlineHolding)
                    outfitMap.updateValue(outlineHolding as NSString, forKey: "bodyShape")
                    
                    //skin tone
                    if let skinName = currentSkinToneFeature?.fileName as NSString? {
                        if skinName.contains("-straight") {
                            let newSkinName = skinName.replacingOccurrences(of: "-straight", with: "")
                            currentSkinToneFeature = BodyFeature(duplicateAndChange: currentSkinToneFeature!, fileName: newSkinName)
                            setImageInView("body", toFeature: currentSkinToneFeature)
                        }
                    }
                }
                else if !isHolding {
                    //outline
                    body.image = UIImage(named: "Body Feature/" + outlineStraight)
                    outfitMap.updateValue(outlineStraight as NSString, forKey: "bodyShape")
                    
                    //skin tone
                    if let skinName = currentSkinToneFeature?.fileName as NSString? {
                        if !skinName.contains("-straight") {
                            let newSkinName = "\(skinName)-straight"
                            currentSkinToneFeature = BodyFeature(duplicateAndChange: currentSkinToneFeature!, fileName: newSkinName)
                            setImageInView("body", toFeature: currentSkinToneFeature)
                        }
                    }
                }
            }
            
            
        }
    }
    
    
    @IBAction func randomize(_ sender: AnyObject) {
        for (className, _) in imageMap! {
            
            //get new image
            let classFeatures = allFeaturesInClass(className)
            if classFeatures.count == 0 { continue }
            let randomChoice = Int(arc4random_uniform(UInt32(classFeatures.count - 1)))
            setImageInView(className, toFeature: classFeatures[randomChoice])
            
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        //show warning alert
        let warning = UIAlertController(title: "Reset Friend", message: "This cannot be undone.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Nevermind", style: .default, handler: nil)
        let resetAction = UIAlertAction(title: "Reset", style: UIAlertActionStyle.destructive, handler: { alert in
            
            //perform reset
            for (className, _) in self.imageMap {
                self.setImageInView(className, toFeature: nil)
                
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        sender.transform = sender.transform.rotated(by: CGFloat(M_PI))
                    }, completion: nil)
            }
            
        })
        
        warning.addAction(cancelAction)
        warning.addAction(resetAction)
        self.present(warning, animated: true, completion: nil)
        
    }
    
    func allFeaturesInClass(_ className: String) -> [BodyFeature] {
        var classFeatures: [BodyFeature] = []
        
        for feature in allFeatures {
            if feature.className == className {
                classFeatures.append(feature)
            }
        }
        
        return classFeatures
    }
    
    
    func createImageOfBody(resize: Bool) -> UIImage {
        
        var fullRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 1152, height: 1728))
        if resize { fullRect = CGRect(origin: CGPoint.zero, size: WWFriendsSize) }
        
        UIGraphicsBeginImageContext(fullRect.size)
        
        if resize {
            //set up antialiasing
            let context = UIGraphicsGetCurrentContext()
            context!.interpolationQuality = CGInterpolationQuality.medium
            context?.setShouldAntialias(true)
        }
        
        for className in classOrder {
            guard let image = imageMap[className]?.image else { continue }
            image.draw(in: fullRect)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    //pragma MARK: - Managing Image Permissions and such
    
    var auth: PHAuthorizationStatus!
    
    @IBAction func saveBodyImage() {
        
        if auth == nil {
            auth = PHPhotoLibrary.authorizationStatus()
        }
        
        //request access
        if auth == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization({ newStatus in
                self.auth = newStatus
                delay(1.0) {
                   self.saveBodyImage()
                }
            })
        }
        
        //no access granted
        if auth == PHAuthorizationStatus.denied {
            //create an alert to send the user to settings
            let alert = UIAlertController(title: "Error", message: "You denied access to the camera roll.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.destructive, handler: nil)
            let fixAction = UIAlertAction(title: "Fix it!", style: .default, handler: { action in

                UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                //hopefully they granted permission. otherwise we're gonna have problems.
                self.auth = PHAuthorizationStatus.authorized
                
            })
            
            alert.addAction(okAction)
            alert.addAction(fixAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        if auth == PHAuthorizationStatus.authorized {
            let image = createImageOfBody(resize: false)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

            let alert = UIAlertController(title: "Saved to Camera Roll", message: nil, preferredStyle: .alert)
            
            //create the accessory image view
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            imageView.alpha = 0.0
            
            let content = UIViewController()
            content.view.addSubview(imageView)
            alert.setValue(content, forKey: "contentViewController")
            
            //add "ok"
            let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(okAction)

            self.present(alert, animated: true, completion: { success in
                let accessoryFrame = content.view.frame
                imageView.frame = CGRect(x: -1.0, y: -5.0, width: accessoryFrame.width, height: accessoryFrame.height * 2.0)
                UIView.animate(withDuration: 0.3, animations: {
                    imageView.alpha = 1.0
                })
            })

        }
        
    }
    
    
    
    //pragma MARK: - Switching Between Collection Views
    
    func showClassCollection(_ className: String) {
        
        let classTitleMap = [
            "bodyShape" : "Body Shape",
            "body" : "Skin Tone",
            "socks" : "Socks",
            "shoes" : "Shoes",
            "pants" : "Pants",
            "belt" : "Belts",
            "shirt" : "Shirts",
            "bowtie" : "Bowties",
            "mouth" : "Mouths",
            "nose" : "Noses",
            "eyes" : "Eyes",
            "hair" : "Hair Styles",
            "glasses" : "Glasses",
            "wrist" : "Small Accessories",
            "hold" : "Big Accessories"
        ]
        
        classTitle.text = classTitleMap[className]
        classDelegate!.setClass(className)
        classCollection.reloadData()
        self.view.layoutIfNeeded()
    
        classConstraint.constant = 0
        classCollection.setContentOffset(CGPoint.zero, animated: false)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.categoryCollection.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            self.categoryCollection.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func closeClassCollection() {
        classConstraint.constant = (classCollection.frame.width + 100)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
            self.categoryCollection.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.categoryCollection.alpha = 1.0
        }, completion: nil)
    }
    
    @IBAction func panOutClassCollection(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: self.view)
        if velocity.x > 1000 {
            closeClassCollection()
        }
    }
    
    
}

//pragma MARK: - Body Feature Data

class BodyFeature {
    
    let fileName: String
    let type: String
    let className: String
    
    init(csvEntry: String) {
        //format: fileName, type, class
        let cells = csvEntry.components(separatedBy: ",")
        fileName = cells[0]
        type = cells[1]
        className = cells[2]
    }
    
    init(duplicateAndChange duplicate: BodyFeature, fileName: String) {
        self.fileName = fileName
        self.type = duplicate.type
        self.className = duplicate.className
    }
    
    func getImage(cropped: Bool) -> UIImage {
        return UIImage(named: "Body Feature/" + (cropped ? "Body Feature Cropped/" : "") + fileName + (cropped ? "#cropped" : ""))!
    }
    
}

//pragma MARK: - Collection View Delegates

class CategoryCollectionDelegate : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    let classOrder = ["body", "hair", "eyes", "nose", "mouth", "glasses", "shirt", "pants", "socks", "shoes", "bowtie", "belt", "wrist", "hold"]
    let controller: BodyViewController

    init(controller: BodyViewController) {
        self.controller = controller
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return classOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        let className = classOrder[index]
        let all = controller.allFeaturesInClass(className)
        let feature = all[5]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feature", for: indexPath) as! BodyCell
        cell.decorate(feature: feature)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.width
        //three items per row with 0px padding
        let width = (collectionWidth - 2.0) / CGFloat(3.0)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let className = classOrder[indexPath.item]
        controller.showClassCollection(className)
    }
    
}

class ClassCollectionDelegate : CategoryCollectionDelegate {
    
    var className: String?
    var features: [BodyFeature]?
    
    func setClass(_ name: String) {
        className = name
        features = controller.allFeaturesInClass(name)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let features = features {
            return features.count + 1
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let features = features {
            
            //clear button must come first
            if indexPath.item == 0 {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "clear", for: indexPath)
            }
            
            let feature = features[indexPath.item - 1]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feature", for: indexPath) as! BodyCell
            cell.decorate(feature: feature)
            
            return cell
            
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "skin", for: indexPath) as UICollectionViewCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            controller.setImageInView(className!, toFeature: nil)
            return
        }
        
        let feature = features![indexPath.item - 1]
        controller.setImageInView(className!, toFeature: feature)
    }
    
}

//pragma MARK: - Collection View Cells

class BodyCell : UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    var featureName: String = ""
    
    func decorate(feature: BodyFeature) {
        image.image = nil //deinit previous
        
        featureName = feature.fileName
        self.backgroundColor = UIColor.white
        self.alpha = 0.0
        
        WWBodyBackgroundThread.async(execute: {
        
            let featureImage = feature.getImage(cropped: true)
            
            DispatchQueue.main.async(execute: {
                self.image.image = featureImage
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 1.0
                })
            })
            
        })
    }

}
