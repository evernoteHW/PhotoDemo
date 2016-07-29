//
//  ViewController.swift
//  PhotoDemo
//
//  Created by WeiHu on 7/1/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class ViewController: UIViewController {
    /// private
    private var _collectionView: UICollectionView!
    private var _bottomCollectionView: UICollectionView!
    
    private var photoArray: [UIImage] = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
           self.configureViews()
           photoArray = getAllPhotos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController: PHPhotoLibraryChangeObserver{
    private func getAllPhotos() -> [UIImage]{
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        let allOptions = PHFetchOptions()
        allOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        let allResults = PHAsset.fetchAssetsWithOptions(allOptions)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        options.version = .Original
        for index in 0..<allResults.count {
            PHCachingImageManager.defaultManager().requestImageForAsset(allResults[index] as! PHAsset, targetSize: CGSizeZero, contentMode: .AspectFit, options: options) { (result: UIImage?, dictionry: Dictionary?) in
                if let result_ = result{
                    self.photoArray.append(result_)
                }
                self._collectionView.reloadData()
            }
        }
        
         return  photoArray


    }
    func photoLibraryDidChange(changeInstance: PHChange){
        getAllPhotos()
    }
//   private func getAllPhotosBeforIOS8() -> [UIImage]{
//    
//        var photoArray = [UIImage]()
////          ALAssetsGroupSavedPhotos表示只读取相机胶卷（ALAssetsGroupAll则读取全部相簿）
//        var assets = [ALAsset]()
//        var countOne = 0
//        var assetsLibrary =  ALAssetsLibrary()
//        assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: {
//            (group: ALAssetsGroup!, stop) in
//            print("is goin")
//            if group != nil
//            {
//                let assetBlock : ALAssetsGroupEnumerationResultsBlock = {
//                    (result: ALAsset!, index: Int, stop) in
//                    if result != nil
//                    {
//                        assets.append(result)
//                        
//                        let myAsset = assets[countOne]
//                        let image = UIImage(CGImage:myAsset.thumbnail().takeUnretainedValue())
//                        photoArray.append(image)
//                        
//                        countOne++
//                    }
//                }
//                group.enumerateAssetsUsingBlock(assetBlock)
//                print("assets:\(countOne)")
//                //collectionView网格重载数据
//                
//            }
//            }, failureBlock: { (fail) in
//                print(fail)
//        })
//        return photoArray
//    }
    
}
class PhotoCollectionViewLayout: UICollectionViewLayout {
    
    private var itemsArrayM = [UICollectionViewLayoutAttributes]()
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionViewContentSize() -> CGSize {
        if let last = itemsArrayM.last{
            return CGSizeMake(self.collectionView!.bounds.width, last.frame.origin.y + last.frame.size.height + 10.0)
        }
        return CGSizeMake(self.collectionView!.bounds.width, 0)
    }
    
    override func prepareLayout() {
        itemsArrayM.removeAll()
   
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        let intervalWidth: CGFloat = 5
//        let samllerWidth: CGFloat = (UIScreen.mainScreen().bounds.width - intervalWidth * 5.0)/4.0
//        let biggerWidth: CGFloat = 2 * samllerWidth + intervalWidth
//        //间隔
//        for index in 0..<self.collectionView!.numberOfItemsInSection(0) {
//            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forRow: index, inSection: 0))
//            switch index {
//            case 0:
//                attributes.frame = CGRectMake(intervalWidth, intervalWidth, biggerWidth, biggerWidth)
//            case 1..<5:
//                x = biggerWidth + 2 * intervalWidth + (samllerWidth + intervalWidth) * CGFloat((index - 1) % 2)
//                y = intervalWidth + (samllerWidth + intervalWidth) * CGFloat(Int((index - 1)/2))
//                attributes.frame = CGRectMake(x, y, samllerWidth, samllerWidth)
//            default:
//                x = intervalWidth + (intervalWidth + samllerWidth) * (CGFloat(index - 5) % 4 )
//                y = biggerWidth + 2 * intervalWidth + (intervalWidth + samllerWidth) * CGFloat(Int((index - 5) / 4))
//                attributes.frame = CGRectMake(x, y, samllerWidth, samllerWidth)
//            }
//            itemsArrayM.append(attributes)
//        }

        let width: CGFloat = (UIScreen.mainScreen().bounds.width - intervalWidth * 4.0)/3.0
        for index in 0..<self.collectionView!.numberOfItemsInSection(0) {
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forRow: index, inSection: 0))
            x = intervalWidth + (intervalWidth + width) * (CGFloat(index) % 3 )
            y = intervalWidth + 2 * intervalWidth + (intervalWidth + width) * CGFloat(Int((index) / 3))
            attributes.frame = CGRectMake(x, y, width, width)
            itemsArrayM.append(attributes)
        }
    }
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return itemsArrayM[indexPath.row]
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return itemsArrayM
    }
}

private extension ViewController{
    private func configureViews(){
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.bottomCollectionView)
        
        self.consraintsForSubViews();
    }
    // views actions
    //getter and setter
    
    private var collectionView: UICollectionView {
        get{
            if _collectionView == nil{
                _collectionView = UICollectionView(frame: CGRectZero,collectionViewLayout: PhotoCollectionViewLayout())
                _collectionView.translatesAutoresizingMaskIntoConstraints = false
                _collectionView.dataSource = self
                _collectionView.delegate = self
                _collectionView.backgroundColor = UIColor.whiteColor()
                _collectionView.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCellID")
            }
            return _collectionView
        }
        set{
            _collectionView = newValue
        }
    }
    
    private var bottomCollectionView: UICollectionView {
        get{
            if _bottomCollectionView == nil{
                _bottomCollectionView = UICollectionView(frame: CGRectZero,collectionViewLayout: PhotoCollectionViewLayout())
                _bottomCollectionView.translatesAutoresizingMaskIntoConstraints = false
                _bottomCollectionView.dataSource = self
                _bottomCollectionView.delegate = self
                _bottomCollectionView.backgroundColor = UIColor.whiteColor()
                _bottomCollectionView.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCellID")
            }
            return _bottomCollectionView
        }
        set{
            _bottomCollectionView = newValue
        }
    }
    //consraintsForSubViews
    private func consraintsForSubViews() {
        //collectionView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": collectionView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": collectionView]))
        
        //bottomCollectionView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": bottomCollectionView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==100)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": bottomCollectionView]))
    }

}
extension ViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.photoArray.count + 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        if collectionView == self.collectionView{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCollectionViewCellID", forIndexPath: indexPath) as! ImageCollectionViewCell
            cell.backgroundColor = UIColor.orangeColor()
            switch indexPath.item {
            case 0:
                break
            default:
                let image = photoArray[indexPath.item - 1]
                cell.imageCollectionSelectedBlock = {[weak self](index) in
                    
                }
                cell.previewImageSelectedBlock = {[weak self](index) in
                    
                }
                cell.imageView.image = image
            }
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCollectionViewCellID", forIndexPath: indexPath) as! ImageCollectionViewCell
            cell.backgroundColor = UIColor.orangeColor()
            switch indexPath.item {
            case 0:
                break
            default:
                let image = photoArray[indexPath.item - 1]
                cell.imageCollectionSelectedBlock = {[weak self](index) in
                    
                }
                cell.previewImageSelectedBlock = {[weak self](index) in
                    
                }
                cell.imageView.image = image
            }
            
            return cell
        }
     
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            let vc = UIImagePickerController()
            vc.sourceType = UIImagePickerControllerSourceType.Camera
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        default:
            let vc = SelectedImageViewController()
            let image = photoArray[indexPath.item - 1]
            vc.oringinImage = image
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismissViewControllerAnimated(true) {
            let vc = SelectedImageViewController()
            vc.oringinImage = image
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}