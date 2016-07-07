
//
//  EffectPhotoViewController.swift
//  PhotoDemo
//
//  Created by WeiHu on 7/4/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

class EffectPhotoViewController: UIViewController {
    /// public
    var oringinImage: UIImage?
    var block: SelecteImageBlock?
    /// private
    
    /// CIBoxBlur CIDiscBlur 
    /*
     CIBoxBlur CICategoryBuiltIn, CICategoryStillImage, CICategoryVideo, CICategoryBlur
     CIDiscBlur CICategoryBuiltIn, CICategoryStillImage, CICategoryVideo, CICategoryBlur
     CIGaussianBlur CICategoryBuiltIn, CICategoryStillImage, CICategoryVideo, CICategoryBlur
     CIMaskedVariableBlur CICategoryBlur, CICategoryVideo, CICategoryStillImage, CICategoryBuiltIn
     CIMedianFilter CICategoryBuiltIn, CICategoryStillImage, CICategoryVideo, CICategoryBlur
     CIMotionBlur CICategoryBuiltIn, CICategoryStillImage, CICategoryVideo, CICategoryBlur
     
     CINoiseReduction CICategoryBuiltIn, CICategoryStillImage, CICategoryVideo, CICategoryBlur
     
     
     CIZoomBlur CICategoryBuiltIn, CICategoryStillImage, CICategoryVideo, CICategoryBlur
     

     */
 
    private var _collectionView: UICollectionView!
    private var _imageHolderView: UIImageView!
    private var _cancelSelectedImageBtn: UIButton!
    private var _confirmSelectedImageBtn: UIButton!
    private var ljNamesArray: [String] =  ["Original","CILinearToSRGBToneCurve","CIPhotoEffectChrome","CIPhotoEffectFade","CIPhotoEffectInstant","CIPhotoEffectMono","CIPhotoEffectProcess","CIPhotoEffectTonal","CIPhotoEffectTransfer"];
    private var effectNameArray: [String] = ["Original","Curve","Chrome","Fade","Instant","Mono","Process","Tonal","Transfer"];
    private var ljImagesArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViews()
        
        let dispatchQueue = dispatch_queue_create("ted.queue.next", DISPATCH_QUEUE_CONCURRENT);
        let dispatchGroup = dispatch_group_create();

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            //所有耗时操作放在该处处理
            for index in 0..<self.ljNamesArray.count{
                dispatch_group_async(dispatchGroup, dispatchQueue) {
                    let image = self.changeImage(self.oringinImage!, withIndex: index, effectArray: self.ljNamesArray)
                    self.ljImagesArray.append(image)
                    print(index)
                }
            }
            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), { 
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //耗时操作执行完成，通知主线程更新UI
                    self.collectionView.reloadData()
                })
            })
        }
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func changeImage(originalImage: UIImage,withIndex index:Int,effectArray: [String]) -> UIImage {
        
        switch (index) {
            case 0:
                return originalImage;
        default:
            return Image(originalImage, withEffect: effectArray[index])
        }
        
    }
  
    func Image(image: UIImage,withEffect effect: String) -> UIImage {
        var effetImage: UIImage?
        //存在内存泄漏
        autoreleasepool { 
            let ciImage = CIImage(image: image)
            let filter = CIFilter(name: effect as String,withInputParameters: [kCIInputImageKey:ciImage!])
            filter?.setDefaults()
            
            let context = CIContext(options: nil)
            let outputImage = filter?.outputImage
            let cgImage = context.createCGImage(outputImage!, fromRect: (outputImage?.extent)!)
            effetImage = UIImage(CGImage: cgImage)
            
        }
        return effetImage!
       }
    

}
extension EffectPhotoViewController{
    private func configureViews(){
        self.edgesForExtendedLayout = .None
        self.view.backgroundColor = UIColor.blackColor()
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.imageHolderView)
        self.view.addSubview(self.cancelSelectedImageBtn)
        self.view.addSubview(self.confirmSelectedImageBtn)
        
        self.consraintsForSubViews();
    }
    // MARK: - views actions
    @objc private func confirmSelectedImageBtnAction(){
        
        if let block = self.block{
            let image = imageHolderView.image
            block(image: image!)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    @objc private func cancelSelectedImageBtnAction(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - getter and setter
    private var imageHolderView: UIImageView {
        get{
            if _imageHolderView == nil{
                _imageHolderView = UIImageView()
                _imageHolderView.translatesAutoresizingMaskIntoConstraints = false
                _imageHolderView.contentMode = .ScaleAspectFit
                _imageHolderView.image = self.oringinImage
            }
            return _imageHolderView
            
        }
        set{
            _imageHolderView = newValue
        }
    }
    private var collectionView: UICollectionView {
        get{
            if _collectionView == nil{
                let layout = UICollectionViewFlowLayout()
                layout.itemSize = CGSizeMake(50, 80)
                layout.minimumLineSpacing = 10
                layout.scrollDirection = .Horizontal
                layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
                
                _collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
                _collectionView.translatesAutoresizingMaskIntoConstraints = false
                _collectionView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
                _collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCellID")
                _collectionView.dataSource = self
                _collectionView.delegate = self
                _collectionView.showsVerticalScrollIndicator = false
                _collectionView.showsHorizontalScrollIndicator = false
                _collectionView.contentOffset = CGPointZero

            }
            return _collectionView
            
        }
        set{
            _collectionView = newValue
        }
        
    }
    private var cancelSelectedImageBtn: UIButton {
        get{
            if _cancelSelectedImageBtn == nil{
                _cancelSelectedImageBtn = UIButton()
                _cancelSelectedImageBtn.translatesAutoresizingMaskIntoConstraints = false
                _cancelSelectedImageBtn.backgroundColor = UIColor.clearColor()
                _cancelSelectedImageBtn.setTitleColor(UIColor.redColor(), forState: .Normal)
                _cancelSelectedImageBtn.setTitle("x", forState: .Normal)
                _cancelSelectedImageBtn.titleLabel?.font = UIFont.systemFontOfSize(30)
                _cancelSelectedImageBtn.addTarget(self, action: #selector(EffectPhotoViewController.cancelSelectedImageBtnAction), forControlEvents: .TouchUpInside)
            }
            return _cancelSelectedImageBtn
            
        }
        set{
            _cancelSelectedImageBtn = newValue
        }
    }
    
    private var confirmSelectedImageBtn: UIButton {
        get{
            if _confirmSelectedImageBtn == nil{
                _confirmSelectedImageBtn = UIButton()
                _confirmSelectedImageBtn.translatesAutoresizingMaskIntoConstraints = false
                _confirmSelectedImageBtn.backgroundColor = UIColor.clearColor()
                _confirmSelectedImageBtn.setTitleColor(UIColor.greenColor(), forState: .Normal)
                _confirmSelectedImageBtn.setTitle("√", forState: .Normal)
                _confirmSelectedImageBtn.titleLabel?.font = UIFont.systemFontOfSize(30)
                _confirmSelectedImageBtn.addTarget(self, action: #selector(EffectPhotoViewController.confirmSelectedImageBtnAction), forControlEvents: .TouchUpInside)
            }
            return _confirmSelectedImageBtn
            
        }
        set{
            _confirmSelectedImageBtn = newValue
        }
    }

    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        //_collectionView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _collectionView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==80)]-30-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _collectionView]))
        
        //imageHolderView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageHolderView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-100-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageHolderView]))
        
        //_cancelSelectedImageBtn
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view(==100)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _cancelSelectedImageBtn]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==30)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _cancelSelectedImageBtn]))
        
        //_confirmSelectedImageBtn
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==100)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _confirmSelectedImageBtn]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==30)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _confirmSelectedImageBtn]))
    }
  
}

extension EffectPhotoViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.ljImagesArray.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UICollectionViewCellID", forIndexPath: indexPath)
        
        let image = self.ljImagesArray[indexPath.row]
        if let imageView_ = cell.contentView.viewWithTag(999) as? UIImageView {
            imageView_.image = image
        }else{
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .ScaleToFill
            imageView.tag = 999
            imageView.image = image
            cell.contentView.addSubview(imageView)
            
            //imageView
            cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view(==50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView]));
            cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view(==50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView]))
        }
        
        let effectName = self.effectNameArray[indexPath.row]
        if let effectNameLabel = cell.contentView.viewWithTag(888) as? UILabel {
            effectNameLabel.text = effectName
        }else{
            let effectNameLabel = UILabel()
            effectNameLabel.translatesAutoresizingMaskIntoConstraints = false
            effectNameLabel.font = UIFont.systemFontOfSize(14)
            effectNameLabel.textColor = UIColor.whiteColor()
            effectNameLabel.textAlignment = .Center
            effectNameLabel.tag = 888
            effectNameLabel.text = effectName
            cell.contentView.addSubview(effectNameLabel)
            
            //effectNameLabel
            cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": effectNameLabel]));
            cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==30)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": effectNameLabel]))
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let image = self.ljImagesArray[indexPath.row]
        imageHolderView.image = image
    }


}