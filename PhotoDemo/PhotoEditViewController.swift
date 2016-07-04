
//
//  PhotoEditViewController.swift
//  PhotoDemo
//
//  Created by WeiHu on 7/1/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

class PhotoEditViewController: UIViewController {
    /// public
    //记录左上角箭头移动的起始位置
    var startPoint1: UnsafeMutablePointer<CGPoint> = UnsafeMutablePointer<CGPoint>.alloc(1)
    //记录左上角箭头移动的起始位置
    var startPoint2: UnsafeMutablePointer<CGPoint> = UnsafeMutablePointer<CGPoint>.alloc(1)
    //记录左下角箭头移动的起始位置
    var startPoint3: UnsafeMutablePointer<CGPoint> = UnsafeMutablePointer<CGPoint>.alloc(1)
    //记录右下角箭头移动的起始位置
    var startPoint4: UnsafeMutablePointer<CGPoint> = UnsafeMutablePointer<CGPoint>.alloc(1)
    
    var startPoint: UnsafeMutablePointer<CGPoint> = UnsafeMutablePointer<CGPoint>.alloc(1)
    
    //记录透明区域移动的起始位置
    var startPointCropView: CGPoint = CGPointZero
    var imageScale: CGFloat = 0.0
    
    //存储不同缩放比例示意图的图片名
    var proportionImageNameArr = ["crop_free", "crop_1_1", "crop_4_3", "crop_3_4", "crop_16_9", "crop_9_16"]
    //存储不同缩放比例示意图的高亮图片名
    var proportionImageNameHLArr = ["cropHL_free", "cropHL_1_1", "cropHL_4_3", "cropHL_3_4", "cropHL_16_9", "cropHL_9_16"]

    //存储不同缩放比例的按钮
    var proportionBtnArr = NSMutableArray()

    //当前待裁剪图片的高宽比
    var imageHWFactor: CGFloat = 0
    
    var oringinImage: UIImage?
    /// private
    private var _blackBgView: UIView!
    private var _usePhotoBtn: UIButton!
    private var _editPhotoBtn: UIButton!
    private var _effectPhotoBtn: UIButton!
    
    let CROPPROPORTIONIMAGEWIDTH: CGFloat = 30.0
    let CROPPROPORTIONIMAGESPACE: CGFloat = 48.0
    let CROPPROPORTIONIMAGEPADDING: CGFloat = 20.0
    let SCREENWIDTH = UIScreen.mainScreen().bounds.width
    let SCREENHEIGHT = UIScreen.mainScreen().bounds.height
    let PADDING: CGFloat = 0.0
    let CROPVIEWBORDERWIDTH: CGFloat = 2.0
    //两个相邻箭头之间的最短距离
    let ARROWMINIMUMSPACE: CGFloat = 20
    //箭头单边的宽度
    let ARROWBORDERWIDTH: CGFloat = 2.0
    let ARROWWIDTH: CGFloat = 25
    let ARROWHEIGHT: CGFloat = 22
    
    
    private var _imageHolderView: UIImageView!
    private var _arrow1: UIImageView!
    private var _arrow2: UIImageView!
    private var _arrow3: UIImageView!
    private var _arrow4: UIImageView!
    private var _scrollView: UIScrollView!
    
    private var _cropView: UIView!
    private var _cropMaskView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.loadImage()
        
        let  cropViewWidth = min(CGRectGetWidth(self.imageHolderView.frame), CGRectGetHeight(self.imageHolderView.frame));
        self.cropView.frame = CGRectMake(0, 0, cropViewWidth, cropViewWidth);
        self.cropView.center = self.imageHolderView.center;
        self.cropView.layer.borderWidth = CROPVIEWBORDERWIDTH;
        self.cropView.layer.borderColor = UIColor.whiteColor().CGColor;
        self.resetAllArrows()
        self.resetCropMask()
        
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
private extension PhotoEditViewController{
    private func loadImage() {
        
        var frame = self.imageHolderView.frame
        frame.size.width = min(frame.size.width, min(SCREENWIDTH - 2 * PADDING, SCREENHEIGHT  - 144 - 44));
        frame.size.height = frame.size.width;
        
        let center = CGPointMake(CGRectGetMidX(UIScreen.mainScreen().bounds), frame.size.height / 2.0 + (SCREENHEIGHT  - 144 - 44 - frame.size.height) / 2.0 + 44);
        imageHWFactor = self.oringinImage!.size.height / self.oringinImage!.size.width;
        if(imageHWFactor <= 1) {
            frame.size.height = imageHWFactor * frame.size.width;
        }
        else {
            frame.size.width = frame.size.height / imageHWFactor;
        }
        imageScale = self.oringinImage!.size.width / CGRectGetWidth(self.imageHolderView.frame);
        self.imageHolderView.frame = frame;
        self.imageHolderView.center = center;
        self.imageHolderView.image = self.oringinImage;
        self.imageHolderView.setNeedsUpdateConstraints()
        
    }
    private func resetCropMask() {
        let path = UIBezierPath(rect: self.cropMaskView.bounds)
        let clearPath = UIBezierPath(rect: CGRectMake(CGRectGetMinX(self.cropView.frame) + CROPVIEWBORDERWIDTH, CGRectGetMinY(self.cropView.frame) + CROPVIEWBORDERWIDTH, CGRectGetWidth(self.cropView.frame) - 2 * CROPVIEWBORDERWIDTH, CGRectGetHeight(self.cropView.frame) - 2 * CROPVIEWBORDERWIDTH)).bezierPathByReversingPath()
        path.appendPath(clearPath)

        var shapeLayer: CAShapeLayer? = self.cropMaskView.layer.mask as? CAShapeLayer
        if(shapeLayer == nil) {
            shapeLayer = CAShapeLayer()
            self.cropMaskView.layer.mask = shapeLayer
        }
        shapeLayer!.path = path.CGPath;
    }
    
    @objc func moveCropView(panGesture: UIPanGestureRecognizer) {
        let minX = CGRectGetMinX(self.imageHolderView.frame);
        let maxX = CGRectGetMaxX(self.imageHolderView.frame) - CGRectGetWidth(self.cropView.frame);
        let minY = CGRectGetMinY(self.imageHolderView.frame);
        let maxY = CGRectGetMaxY(self.imageHolderView.frame) - CGRectGetHeight(self.cropView.frame);
        
        if(panGesture.state == .Began) {
            startPointCropView = panGesture.locationInView(self.cropMaskView)
            self.arrow1.userInteractionEnabled = false;
            self.arrow2.userInteractionEnabled = false;
            self.arrow3.userInteractionEnabled = false;
            self.arrow4.userInteractionEnabled = false;
        }
        else if(panGesture.state == .Ended) {
            self.arrow1.userInteractionEnabled = true;
            self.arrow2.userInteractionEnabled = true;
            self.arrow3.userInteractionEnabled = true;
            self.arrow4.userInteractionEnabled = true;
        }
        else if(panGesture.state == .Changed) {
            let endPoint = panGesture.locationInView(self.cropMaskView)
            var frame = panGesture.view!.frame;
            frame.origin.x += endPoint.x - startPointCropView.x;
            frame.origin.y += endPoint.y - startPointCropView.y;
            frame.origin.x = min(maxX, max(frame.origin.x, minX));
            frame.origin.y = min(maxY, max(frame.origin.y, minY));
            panGesture.view!.frame = frame;
            startPointCropView = endPoint;
        }
        self.resetCropMask()
        self.resetAllArrows()
    
    }
    @objc func moveCorner(panGesture: UIPanGestureRecognizer) {
        
        
        var minX = CGRectGetMinX(self.imageHolderView.frame) - ARROWBORDERWIDTH;
        var maxX = CGRectGetMaxX(self.imageHolderView.frame) - ARROWWIDTH + ARROWBORDERWIDTH;
        var minY = CGRectGetMinY(self.imageHolderView.frame) - ARROWBORDERWIDTH;
        var maxY = CGRectGetMaxY(self.imageHolderView.frame) - ARROWHEIGHT + ARROWBORDERWIDTH;
        
        switch panGesture.view as! UIImageView{
            case self.arrow1 :
                startPoint = startPoint1;
                maxY = CGRectGetMinY(self.arrow3.frame) - ARROWHEIGHT - ARROWMINIMUMSPACE;
                maxX = CGRectGetMinX(self.arrow2.frame) - ARROWWIDTH - ARROWMINIMUMSPACE;
            case self.arrow2:
                startPoint = startPoint2;
                maxY = CGRectGetMinY(self.arrow4.frame) - ARROWHEIGHT - ARROWMINIMUMSPACE;
                minX = CGRectGetMaxX(self.arrow1.frame) + ARROWMINIMUMSPACE;
            case self.arrow3:
                startPoint = startPoint3;
                minY = CGRectGetMaxY(self.arrow1.frame) + ARROWMINIMUMSPACE;
                maxX = CGRectGetMinX(self.arrow4.frame) - ARROWWIDTH - ARROWMINIMUMSPACE;
            case self.arrow4:
                startPoint = startPoint4;
                minY = CGRectGetMaxY(self.arrow2.frame) + ARROWMINIMUMSPACE;
                minX = CGRectGetMaxX(self.arrow3.frame) + ARROWMINIMUMSPACE;

        default:
            break
        }
        
        switch panGesture.state {
            case .Began:
                startPoint.memory = panGesture.locationInView(self.cropMaskView)
                self.cropView.userInteractionEnabled = false;
            case .Changed:
                let endPoint = panGesture.locationInView(self.cropMaskView)
                var frame = panGesture.view!.frame
                frame.origin.x += endPoint.x - startPoint.memory.x
                frame.origin.y += endPoint.y - startPoint.memory.y
                frame.origin.x = min(maxX, max(frame.origin.x, minX));
                frame.origin.y = min(maxY, max(frame.origin.y, minY));
                panGesture.view!.frame = frame;
                startPoint.memory = endPoint;
            case .Ended:
                self.cropView.userInteractionEnabled = true;
        default:
            break
        }
        self.resetArrowsFollow(panGesture.view!)
        self.resetCropView()
        self.resetCropMask()
    }
    func resetArrowsFollow(arrow: UIView) {
    
        let borderMinY = CGRectGetMinY(self.imageHolderView.frame);
        let borderMaxY = CGRectGetMaxY(self.imageHolderView.frame);
        
        switch arrow {
            case self.arrow1:
        
                let leftTopPoint = CGPointMake(CGRectGetMinX(self.arrow1.frame) + ARROWBORDERWIDTH, CGRectGetMinY(self.arrow1.frame) + ARROWBORDERWIDTH);
                var frame = self.cropView.frame;
                let maxX = CGRectGetMaxX(frame);
                let maxY = CGRectGetMaxY(frame);
        
                frame.size.height = min(max(maxX - leftTopPoint.x, 2 * ARROWWIDTH + ARROWMINIMUMSPACE) , maxY - borderMinY);
                frame.size.width = frame.size.height ;
             
                frame.origin.x = maxX - frame.size.width;
                frame.origin.y = maxY - frame.size.height;
                self.cropView.frame = frame;
                self.resetAllArrows()
            
            case self.arrow2:

                let rightTopPoint = CGPointMake(CGRectGetMaxX(self.arrow2.frame) - ARROWBORDERWIDTH, CGRectGetMinY(self.arrow2.frame) + ARROWBORDERWIDTH);
                var frame = self.cropView.frame;
                let minX = CGRectGetMinX(frame);
                let maxY = CGRectGetMaxY(frame);
           
                frame.size.height = min(max(rightTopPoint.x - minX, 2 * ARROWWIDTH + ARROWMINIMUMSPACE) , maxY - borderMinY);
                frame.size.width = frame.size.height ;
         
                frame.origin.y = maxY - frame.size.height;
                self.cropView.frame = frame;
                
                self.resetAllArrows()
            case self.arrow3:
    
                let leftBottomPoint = CGPointMake(CGRectGetMinX(self.arrow3.frame) + ARROWBORDERWIDTH, CGRectGetMaxY(self.arrow3.frame) - ARROWBORDERWIDTH);
                var frame = self.cropView.frame;
                let maxX = CGRectGetMaxX(frame);
                let minY = CGRectGetMinY(frame);
        
                frame.size.height = min(max(maxX - leftBottomPoint.x, 2 * ARROWWIDTH + ARROWMINIMUMSPACE) , borderMaxY - minY);
                frame.size.width = frame.size.height ;
            
                
                frame.origin.x = maxX - frame.size.width;
                self.cropView.frame = frame;
                
                self.resetAllArrows()
            case self.arrow4:

                let rightBottomPoint = CGPointMake(CGRectGetMaxX(self.arrow4.frame) - ARROWBORDERWIDTH, CGRectGetMaxY(self.arrow4.frame) - ARROWBORDERWIDTH);
                var frame = self.cropView.frame;
                let minX = CGRectGetMinX(frame);
                let minY = CGRectGetMinY(frame);
    
                frame.size.height = min(max(rightBottomPoint.x - minX, 2 * ARROWWIDTH + ARROWMINIMUMSPACE) , borderMaxY - minY);
                frame.size.width = frame.size.height ;
            self.cropView.frame = frame;
                self.resetAllArrows()
        default:
            break
        }
        
     
    }
    
    private func resetAllArrows() {
        self.arrow1.center = CGPointMake(CGRectGetMinX(self.cropView.frame) - ARROWBORDERWIDTH + ARROWWIDTH/2.0, CGRectGetMinY(self.cropView.frame) - ARROWBORDERWIDTH + ARROWHEIGHT/2.0);
        self.arrow2.center = CGPointMake(CGRectGetMaxX(self.cropView.frame) + ARROWBORDERWIDTH - ARROWWIDTH/2.0, CGRectGetMinY(self.cropView.frame) - ARROWBORDERWIDTH + ARROWHEIGHT/2.0);
        self.arrow3.center = CGPointMake(CGRectGetMinX(self.cropView.frame) - ARROWBORDERWIDTH + ARROWWIDTH/2.0, CGRectGetMaxY(self.cropView.frame) + ARROWBORDERWIDTH - ARROWHEIGHT/2.0);
        self.arrow4.center = CGPointMake(CGRectGetMaxX(self.cropView.frame) + ARROWBORDERWIDTH - ARROWWIDTH/2.0, CGRectGetMaxY(self.cropView.frame) + ARROWBORDERWIDTH - ARROWHEIGHT/2.0);
        self.view.layoutIfNeeded()
    }
    func resetCropView() {
       self.cropView.frame = CGRectMake(CGRectGetMinX(self.arrow1.frame) + ARROWBORDERWIDTH, CGRectGetMinY(self.arrow1.frame) + ARROWBORDERWIDTH, CGRectGetMaxX(self.arrow2.frame) - CGRectGetMinX(self.arrow1.frame) - ARROWBORDERWIDTH * 2, CGRectGetMaxY(self.arrow3.frame) - CGRectGetMinY(self.arrow1.frame) - ARROWBORDERWIDTH * 2);
    }
    private func cropAreaInImage() -> CGRect  {
        let cropAreaInImageView = self.cropMaskView.convertRect(self.cropView.frame, toView: self.imageHolderView)
        var cropAreaInImage: CGRect = CGRectZero;
        cropAreaInImage.origin.x = cropAreaInImageView.origin.x * imageScale;
        cropAreaInImage.origin.y = cropAreaInImageView.origin.y * imageScale;
        cropAreaInImage.size.width = cropAreaInImageView.size.width * imageScale;
        cropAreaInImage.size.height = cropAreaInImageView.size.height * imageScale;
        return cropAreaInImage;
    }
    private func clickProportionBtn()  {
    
    }
}
extension PhotoEditViewController: UIScrollViewDelegate{
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageHolderView
    }
}
private extension PhotoEditViewController{
    private func configureViews(){
        self.edgesForExtendedLayout = .None
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.blackBgView)
        self.view.addSubview(self.scrollView)
        
//        self.view.addSubview(self.cropMaskView)
        
        self.consraintsForSubViews();
    }
    // MARK: - views actions
    // MARK: - getter and setter
   
    private var scrollView: UIScrollView {
        get{
            if _scrollView == nil{
                _scrollView = UIScrollView()
                _scrollView.translatesAutoresizingMaskIntoConstraints = false
                _scrollView.backgroundColor = UIColor.clearColor()
                _scrollView.delegate = self
                _scrollView.minimumZoomScale = 1
                _scrollView.maximumZoomScale = 2
                
                _scrollView.addSubview(self.imageHolderView)
                
                _scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _imageHolderView]));
                _scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _imageHolderView]))
            }
            return _scrollView
            
        }
        set{
            _scrollView = newValue
        }
    }
    private var imageHolderView: UIImageView {
        get{
            if _imageHolderView == nil{
                _imageHolderView = UIImageView()
                _imageHolderView.translatesAutoresizingMaskIntoConstraints = false
//                _imageHolderView.frame = CGRectMake(0, 72, SCREENWIDTH, 344)
                _imageHolderView.contentMode = .ScaleAspectFit
                
            }
            return _imageHolderView
            
        }
        set{
            _imageHolderView = newValue
        }
    }
      private var cropMaskView: UIView {
        get{
            if _cropMaskView == nil{
                _cropMaskView = UIView()
                _cropMaskView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 100)
                _cropMaskView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
                
                _cropMaskView.addSubview(self.cropView)
                
                _cropMaskView.addSubview(arrow1)
                _cropMaskView.addSubview(arrow2)
                _cropMaskView.addSubview(arrow3)
                _cropMaskView.addSubview(arrow4)
            }
            return _cropMaskView
            
        }
        set{
            _cropMaskView = newValue
        }
    }
    private var cropView: UIView {
        get{
            if _cropView == nil{
                _cropView = UIView()
                _cropView.backgroundColor = UIColor.clearColor()
                _cropView.frame = CGRectMake(10, 72, 355, 344)
                
                let pan = UIPanGestureRecognizer(target: self ,action: #selector(PhotoEditViewController.moveCropView(_:)))
                _cropView.addGestureRecognizer(pan)
            }
            return _cropView
        }
        set{
            _cropView = newValue
        }
    }
    
    private var arrow1: UIImageView {
        get{
            if _arrow1 == nil{
                _arrow1 = UIImageView()
                _arrow1.frame = CGRectMake(10, 72, 25, 22)
                _arrow1.backgroundColor = UIColor.clearColor()
                _arrow1.image = UIImage(named: "arrow1")
                _arrow1.contentMode = .ScaleAspectFit
                _arrow1.userInteractionEnabled = true
                
                let pan = UIPanGestureRecognizer(target: self ,action: #selector(PhotoEditViewController.moveCorner(_:)))
                _arrow1.addGestureRecognizer(pan)
            }
            return _arrow1
            
        }
        set{
            _arrow1 = newValue
        }
    }
    private var arrow2: UIImageView {
        get{
            if _arrow2 == nil{
                _arrow2 = UIImageView()
                _arrow2.backgroundColor = UIColor.clearColor()
                _arrow2.frame = CGRectMake(340, 72, 25, 22)
                _arrow2.contentMode = .ScaleAspectFit
                _arrow2.image = UIImage(named: "arrow2")
                _arrow2.userInteractionEnabled = true
                
                let pan = UIPanGestureRecognizer(target: self ,action: #selector(PhotoEditViewController.moveCorner(_:)))
                _arrow2.addGestureRecognizer(pan)
            }
            return _arrow2
            
        }
        set{
            _arrow2 = newValue
        }
    }
    private var arrow3: UIImageView {
        get{
            if _arrow3 == nil{
                _arrow3 = UIImageView()
                _arrow3.backgroundColor = UIColor.clearColor()
                _arrow3.frame = CGRectMake(10, 394, 25, 22)
                _arrow3.contentMode = .ScaleAspectFit
                _arrow3.image = UIImage(named: "arrow3")
                _arrow3.userInteractionEnabled = true
                
                let pan = UIPanGestureRecognizer(target: self ,action: #selector(PhotoEditViewController.moveCorner(_:)))
                _arrow3.addGestureRecognizer(pan)
            }
            return _arrow3
            
        }
        set{
            _arrow3 = newValue
        }
    }
    private var arrow4: UIImageView {
        get{
            if _arrow4 == nil{
                _arrow4 = UIImageView()
                _arrow4.backgroundColor = UIColor.clearColor()
                _arrow4.frame = CGRectMake(340, 394, 25, 22)
                _arrow4.contentMode = .ScaleAspectFit
                _arrow4.image = UIImage(named: "arrow4")
                _arrow4.userInteractionEnabled = true
                
                let pan = UIPanGestureRecognizer(target: self ,action: #selector(PhotoEditViewController.moveCorner(_:)))
                _arrow4.addGestureRecognizer(pan)
            }
            return _arrow4
            
        }
        set{
            _arrow4 = newValue
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
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _scrollView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _scrollView]))

    }
    
}