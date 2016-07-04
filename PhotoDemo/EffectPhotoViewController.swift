
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
    
    /// private
    private var _collectionView: UICollectionView!
    private var _imageHolderView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViews()
        //    1.源图
        let inputImage = CIImage(image: self.oringinImage!);
        //    2.滤镜
        let filter = CIFilter(name: "CIColorMonochrome")
        //    NSLog(@"%@",[CIFilter filterNamesInCategory:kCICategoryColorEffect]);//注意此处两个输出语句的重要作用
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(CIColor(red:1.000 ,green: 0.165, blue: 0.176), forKey: kCIInputColorKey)
        let outImage = filter!.outputImage;
        
        let filter2 = CIFilter(name: "CISepiaTone")
        filter2?.setValue(outImage, forKey: kCIInputImageKey)
        filter2?.setValue(0.5, forKey: kCIInputColorKey)
        //    在这里创建上下文  把滤镜和图片进行合并
        let context = CIContext()
        let resultImage = context.createCGImage(filter2!.outputImage!, fromRect: filter2!.outputImage!.extent)
        imageHolderView.image = UIImage(CGImage: resultImage)
        
        
        imageHolderView.image = self.oringinImage
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension EffectPhotoViewController{
    private func configureViews(){
        self.edgesForExtendedLayout = .None
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.imageHolderView)
        self.consraintsForSubViews();
    }
    // MARK: - views actions
    // MARK: - getter and setter
    private var imageHolderView: UIImageView {
        get{
            if _imageHolderView == nil{
                _imageHolderView = UIImageView()
                _imageHolderView.translatesAutoresizingMaskIntoConstraints = false
                _imageHolderView.contentMode = .ScaleAspectFit
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
                layout.itemSize = CGSizeMake(50, 50)
                layout.minimumLineSpacing = 10
                layout.scrollDirection = .Horizontal
                layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
                
                _collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
                _collectionView.translatesAutoresizingMaskIntoConstraints = false
                _collectionView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
                _collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCellID")
                _collectionView.dataSource = self
                _collectionView.delegate = self
                _collectionView.contentOffset = CGPointZero

            }
            return _collectionView
            
        }
        set{
            _collectionView = newValue
        }
        
    }

    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        //_collectionView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _collectionView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==100)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _collectionView]))
        
        //imageHolderView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageHolderView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-100-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageHolderView]))
    }
  
}

extension EffectPhotoViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 10
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UICollectionViewCellID", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.whiteColor()
        if let imageView_ = cell.contentView.viewWithTag(999) as? UIImageView {
            imageView_.image = self.oringinImage
        }else{
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .ScaleToFill
            imageView.tag = 999
            imageView.image = self.oringinImage
            cell.contentView.addSubview(imageView)
            
            //imageView
            cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView]));
            cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView]))
        }
        return cell
    }


}