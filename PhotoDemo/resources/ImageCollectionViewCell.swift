//
//  ImageCollectionViewCell.swift
//  PhotoDemo
//
//  Created by WeiHu on 16/7/29.
//  Copyright © 2016年 WeiHu. All rights reserved.
//

import UIKit

typealias ImageCollectionSelectedBlock = (index:NSInteger)->Void
typealias PreviewImageSelectedBlock = (index:NSInteger)->Void

class ImageCollectionViewCell: UICollectionViewCell {
    private var _imageView: UIImageView!
    private var _selectedPicImageView: UIImageView!
    
    var index: NSInteger!
    
    var imageCollectionSelectedBlock: ImageCollectionSelectedBlock!
    var previewImageSelectedBlock: PreviewImageSelectedBlock!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageCollectionViewCell{
    
    func configureViews(){
        contentView.addSubview(imageView)
        contentView.addSubview(selectedPicImageView)
        consraintsForSubViews();
        
    }
    // MARK: - views actions
    @objc func selectedPicImageViewAction(){
        if let block = imageCollectionSelectedBlock{
            block(index: self.index)
        }
    }
  
    @objc func imageViewAction(){
        if let block = previewImageSelectedBlock{
            block(index: self.index)
        }
    }
    
    // MARK: - getter and setter
    var imageView: UIImageView {
        get{
            if _imageView == nil{
                _imageView = UIImageView()
                _imageView.translatesAutoresizingMaskIntoConstraints = false
                _imageView.backgroundColor = UIColor.clearColor()
                _imageView.contentMode = .ScaleAspectFit
                
                _imageView.userInteractionEnabled = true
                _imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImageCollectionViewCell.imageViewAction)))
                
            }
            return _imageView
            
        }
        set{
            _imageView = newValue
        }
    }
    
    private var selectedPicImageView: UIImageView {
        get{
            if _selectedPicImageView == nil{
                _selectedPicImageView = UIImageView()
                _selectedPicImageView.translatesAutoresizingMaskIntoConstraints = false
                _selectedPicImageView.backgroundColor = UIColor.redColor()
                _selectedPicImageView.contentMode = .ScaleAspectFit
                
                _selectedPicImageView.userInteractionEnabled = true
                
                _selectedPicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImageCollectionViewCell.selectedPicImageViewAction)))
            }
            return _selectedPicImageView
            
        }
        set{
            _selectedPicImageView = newValue
        }
    }
    
    
    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        //imageView
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView]));
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": imageView]))
        
        //selectedPicImageView
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==50)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": selectedPicImageView]));
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view(==50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": selectedPicImageView]))
      
    }
}
