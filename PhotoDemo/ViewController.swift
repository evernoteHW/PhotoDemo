//
//  ViewController.swift
//  PhotoDemo
//
//  Created by WeiHu on 7/1/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit
import AssetsLibrary

class ViewController: UIViewController {
    /// private
    private var _collectionView: UICollectionView!
    //资源库管理类
    private var assetsLibrary =  ALAssetsLibrary()
    //保存照片集合
    private var assets = [ALAsset]()
    /// public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var countOne = 0
        //ALAssetsGroupSavedPhotos表示只读取相机胶卷（ALAssetsGroupAll则读取全部相簿）
        assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: {
            (group: ALAssetsGroup!, stop) in
            print("is goin")
            if group != nil
            {
                let assetBlock : ALAssetsGroupEnumerationResultsBlock = {
                    (result: ALAsset!, index: Int, stop) in
                    if result != nil
                    {
                        self.assets.append(result)
                        countOne++
                    }
                }
                group.enumerateAssetsUsingBlock(assetBlock)
                print("assets:\(countOne)")
                //collectionView网格重载数据
                self.collectionView.reloadData()
            }
            }, failureBlock: { (fail) in
                print(fail)
        })
        
        self.configureViews()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
        let samllerWidth: CGFloat = (UIScreen.mainScreen().bounds.width - intervalWidth * 5.0)/4.0
        let biggerWidth: CGFloat = 2 * samllerWidth + intervalWidth
        //间隔
        for index in 0..<self.collectionView!.numberOfItemsInSection(0) {
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forRow: index, inSection: 0))
            switch index {
            case 0:
                attributes.frame = CGRectMake(intervalWidth, intervalWidth, biggerWidth, biggerWidth)
            case 1..<5:
                x = biggerWidth + 2 * intervalWidth + (samllerWidth + intervalWidth) * CGFloat((index - 1) % 2)
                y = intervalWidth + (samllerWidth + intervalWidth) * CGFloat(Int((index - 1)/2))
                attributes.frame = CGRectMake(x, y, samllerWidth, samllerWidth)
            default:
                x = intervalWidth + (intervalWidth + samllerWidth) * (CGFloat(index - 5) % 4 )
                y = biggerWidth + 2 * intervalWidth + (intervalWidth + samllerWidth) * CGFloat(Int((index - 5) / 4))
                attributes.frame = CGRectMake(x, y, samllerWidth, samllerWidth)
            }
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
                _collectionView.backgroundColor = UIColor.yellowColor()
                _collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCellID")
            }
            return _collectionView
        }
        set{
            _collectionView = newValue
        }
    }
    //consraintsForSubViews
    private func consraintsForSubViews() {
        //collectionView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": collectionView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": collectionView]))
    }

}
extension ViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.assets.count + 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UICollectionViewCellID", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.orangeColor()
        switch indexPath.item {
        case 0:
            break
        default:
            let myAsset = assets[indexPath.item - 1]
            let image = UIImage(CGImage:myAsset.thumbnail().takeUnretainedValue())
            
            var imageView = (cell.contentView.viewWithTag(99) as? UIImageView)
            
            if let _ = imageView{
                
            }else{
                imageView = UIImageView()
                imageView!.translatesAutoresizingMaskIntoConstraints = false
                imageView!.backgroundColor = UIColor.clearColor()
                imageView!.contentMode = .ScaleAspectFit
                imageView!.tag = 99
                cell.contentView.addSubview(imageView!)
                
                //imageView
                cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView!]));
                cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView!]))
            }
            imageView?.image = image
        }
      
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            let vc = UIImagePickerController()
            vc.sourceType = UIImagePickerControllerSourceType.Camera
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        default:
            let vc = UIImagePickerController()
            vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
      
    }
    
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        print(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
}