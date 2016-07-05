//
//  SelectedImageViewController.swift
//  PhotoDemo
//
//  Created by WeiHu on 7/4/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

@objc class SelectedImageViewController: UIViewController {
    
    var oringinImage: UIImage?
    /// private
    private var _blackBgView: UIView!
    private var _usePhotoBtn: UIButton!
    private var _editPhotoBtn: UIButton!
    private var _effectPhotoBtn: UIButton!
    private var _imageHolderView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
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

private extension SelectedImageViewController{
    private func configureViews(){
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.imageHolderView)
        self.view.addSubview(self.blackBgView)
        self.consraintsForSubViews();
    }
    // MARK: - views actions
    @objc func editPhotoBtnAction() {
        let vc = PhotoEditViewController()
        vc.oringinImage = self.imageHolderView.image
        vc.block = {[weak self](image) in
            if let strongSelf = self{
                strongSelf.imageHolderView.image = image
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func effectPhotoBtnAction() {
        let vc = EffectPhotoViewController()
        vc.oringinImage = self.imageHolderView.image
        vc.block = {[weak self](image) in
            if let strongSelf = self{
                strongSelf.imageHolderView.image = image
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: - getter and setter
    private var imageHolderView: UIImageView {
        get{
            if _imageHolderView == nil{
                _imageHolderView = UIImageView()
                _imageHolderView.translatesAutoresizingMaskIntoConstraints = false
                _imageHolderView.contentMode = .ScaleAspectFit
                _imageHolderView.backgroundColor = UIColor.orangeColor()
            }
            return _imageHolderView
            
        }
        set{
            _imageHolderView = newValue
        }
    }
      private var blackBgView: UIView {
        get{
            if _blackBgView == nil{
                _blackBgView = UIView()
                _blackBgView.translatesAutoresizingMaskIntoConstraints = false
                _blackBgView.backgroundColor = UIColor.blackColor()
                
                _blackBgView.addSubview(self.usePhotoBtn)
                _blackBgView.addSubview(self.editPhotoBtn)
                _blackBgView.addSubview(self.effectPhotoBtn)
                
                //_usePhotoBtn
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==100)]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _usePhotoBtn]));
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==50)]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _usePhotoBtn]))
                
                //_editPhotoBtn
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==60)]-120-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _editPhotoBtn]));
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==50)]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _editPhotoBtn]))
                
                //_effectPhotoBtn
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==60)]-190-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _effectPhotoBtn]));
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==50)]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _effectPhotoBtn]))
            }
            return _blackBgView
            
        }
        set{
            _blackBgView = newValue
        }
    }
    
    private var usePhotoBtn: UIButton {
        get{
            if _usePhotoBtn == nil{
                _usePhotoBtn = UIButton()
                _usePhotoBtn.translatesAutoresizingMaskIntoConstraints = false
                _usePhotoBtn.backgroundColor = UIColor.orangeColor()
                _usePhotoBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                _usePhotoBtn.setTitle("使用照片", forState: .Normal)
                _usePhotoBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
            }
            return _usePhotoBtn
            
        }
        set{
            _usePhotoBtn = newValue
        }
    }
    
    private var editPhotoBtn: UIButton {
        get{
            if _editPhotoBtn == nil{
                _editPhotoBtn = UIButton()
                _editPhotoBtn.translatesAutoresizingMaskIntoConstraints = false
                _editPhotoBtn.backgroundColor = UIColor.yellowColor()
                _editPhotoBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                _editPhotoBtn.setTitle("裁剪", forState: .Normal)
                _editPhotoBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
                _editPhotoBtn.addTarget(self, action: #selector(SelectedImageViewController.editPhotoBtnAction), forControlEvents: .TouchUpInside)
            }
            return _editPhotoBtn
            
        }
        set{
            _editPhotoBtn = newValue
        }
    }
    private var effectPhotoBtn: UIButton {
        get{
            if _effectPhotoBtn == nil{
                _effectPhotoBtn = UIButton()
                _effectPhotoBtn.translatesAutoresizingMaskIntoConstraints = false
                _effectPhotoBtn.backgroundColor = UIColor.redColor()
                _effectPhotoBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                _effectPhotoBtn.setTitle("滤镜", forState: .Normal)
                _effectPhotoBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
                _effectPhotoBtn.addTarget(self, action: #selector(SelectedImageViewController.effectPhotoBtnAction), forControlEvents: .TouchUpInside)
            }
            return _effectPhotoBtn
            
        }
        set{
            _effectPhotoBtn = newValue
        }
    }
    
    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        //_blackBgView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _blackBgView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==100)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _blackBgView]))
        
        //imageHolderView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageHolderView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-100-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageHolderView]))
    }
    
}