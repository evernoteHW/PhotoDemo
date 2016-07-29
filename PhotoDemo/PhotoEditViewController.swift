
//
//  PhotoEditViewController.swift
//  PhotoDemo
//
//  Created by WeiHu on 7/1/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

enum BtnType {
    case None
    case LeftUp
    case RightUp
    case LeftDown
    case RighDown
    case Center
}

typealias SelecteImageBlock = (image:UIImage)->Void

class PhotoEditViewController: UIViewController {
    /// public
    var block: SelecteImageBlock?
    var oringinImage: UIImage?
    
    /// private
    private var _blackBgView: UIView!
    private var _cancelSelectedImageBtn: UIButton!
    private var _confirmSelectedImageBtn: UIButton!
    private var _imageHolderView: UIImageView!
    private var _scrollView: DemoScrollView!
    private var _cropView: UIView!
    private var _cropMaskView: UIView!

    private var layoutConstraint_left: NSLayoutConstraint!
    private var layoutConstraint_width: NSLayoutConstraint!
    private var layoutConstraint_top: NSLayoutConstraint!
    private var layoutConstraint_height: NSLayoutConstraint!
    
    private var startedPoint: CGPoint = CGPointZero
    private var btnType: BtnType = .None
    private var demoViewStartedFrame: CGRect = CGRectZero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViews()
        self.loadImage()
        self.resetCropMask()
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
private extension PhotoEditViewController{
    private func loadImage() {
        
        let frame = self.imageHolderView.frame
        self.imageHolderView.image = self.oringinImage

        let imageSize = self.imageHolderView.image!.size//获得图片的size
        var imageFrame = CGRectMake(0, 0,imageSize.width, imageSize.height)

        let ratio = frame.size.width/imageFrame.size.width
        imageFrame.size.height = imageFrame.size.height*ratio
        imageFrame.size.width = frame.size.width
        
        self.imageHolderView.frame = imageFrame
        self.scrollView.contentSize = self.imageHolderView.frame.size
        self.imageHolderView.center = self.centerOfScrollViewContent()
    
        //根据图片大小找到最大缩放等级，保证最大缩放时候，不会有黑边
        var maxScale: CGFloat = frame.size.height/imageFrame.size.height
        maxScale = (frame.size.width/imageFrame.size.width>maxScale) ? (frame.size.width/imageFrame.size.width) : maxScale
        //超过了设置的最大的才算数
        maxScale = max(maxScale, 2.0)
        //初始化
        self.scrollView.maximumZoomScale = maxScale
        
        let  cropViewWidth = min(CGRectGetWidth(self.imageHolderView.frame), CGRectGetHeight(self.imageHolderView.frame))
        
        layoutConstraint_width.constant = cropViewWidth
        layoutConstraint_height.constant = cropViewWidth
        layoutConstraint_top.constant = imageHolderView.center.y - cropViewWidth/2.0
        layoutConstraint_left.constant = imageHolderView.center.x - cropViewWidth/2.0
        

    }
    private func resetCropMask() {
        let path = UIBezierPath(rect: self.cropMaskView.bounds)
        let clearPath = UIBezierPath(rect: CGRectMake(layoutConstraint_left.constant, layoutConstraint_top.constant, layoutConstraint_width.constant, layoutConstraint_height.constant)).bezierPathByReversingPath()
        path.appendPath(clearPath)

        var shapeLayer: CAShapeLayer? = self.cropMaskView.layer.mask as? CAShapeLayer
        if(shapeLayer == nil) {
            shapeLayer = CAShapeLayer()
            self.cropMaskView.layer.mask = shapeLayer
        }
        shapeLayer!.path = path.CGPath
    }
    

}
extension PhotoEditViewController{
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let point: CGPoint = touch?.locationInView(self.view) ?? CGPointZero
        startedPoint = point
        demoViewStartedFrame = self.cropView.frame
        //最原始的位置
        
        if CGRectContainsPoint(cropView.frame, point){
            let pointFingerInView: CGPoint = touch?.locationInView(cropView) ?? CGPointZero
            if CGRectContainsPoint(CGRectMake(0, 0, 50, 50), pointFingerInView){
                btnType = .LeftUp
            }else if CGRectContainsPoint(CGRectMake(cropView.frame.size.width - 50, 0, 50, 50), pointFingerInView){
                btnType = .RightUp
            }else if CGRectContainsPoint(CGRectMake(0,  cropView.frame.size.height - 50, 50, 50), pointFingerInView){
                btnType = .LeftDown
            }else if CGRectContainsPoint(CGRectMake( cropView.frame.size.width - 50,  cropView.frame.size.height - 50, 50, 50), pointFingerInView){
                btnType = .RighDown
            }else{
                btnType = .Center
            }
        }
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let point: CGPoint = touch?.locationInView(self.view) ?? CGPointZero
        
        let movedWidth = point.x - startedPoint.x
        let movedHeight = point.y - startedPoint.y
        //设置最大和最小值
        //最小值 2 个按钮 宽度 + 中间间隔
        
        switch btnType {
        case .None:
            break
        case .LeftUp:
            layoutConstraint_left.constant = CGRectGetMinX(demoViewStartedFrame) + movedWidth
            layoutConstraint_width.constant = CGRectGetMaxX(demoViewStartedFrame) - layoutConstraint_left.constant
            layoutConstraint_top.constant = CGRectGetMinY(demoViewStartedFrame) + movedHeight
            layoutConstraint_height.constant = CGRectGetMaxY(demoViewStartedFrame) - layoutConstraint_top.constant
        case .RightUp:
            layoutConstraint_width.constant = CGRectGetWidth(demoViewStartedFrame) + movedWidth
            layoutConstraint_top.constant = CGRectGetMinY(demoViewStartedFrame) + movedHeight
            layoutConstraint_height.constant = CGRectGetMaxY(demoViewStartedFrame) - layoutConstraint_top.constant
        case .LeftDown:
            layoutConstraint_left.constant = CGRectGetMinX(demoViewStartedFrame) + movedWidth
            layoutConstraint_width.constant = CGRectGetMaxX(demoViewStartedFrame) - layoutConstraint_left.constant
            layoutConstraint_height.constant = CGRectGetHeight(demoViewStartedFrame) + movedHeight
        case .RighDown:
            layoutConstraint_width.constant = CGRectGetWidth(demoViewStartedFrame) + movedWidth
            layoutConstraint_height.constant = CGRectGetHeight(demoViewStartedFrame) + movedHeight
        case .Center:
            layoutConstraint_left.constant = demoViewStartedFrame.origin.x + movedWidth
            layoutConstraint_top.constant = demoViewStartedFrame.origin.y + movedHeight
        }
        let rect = imageHolderView.convertRect(imageHolderView.frame, toView: self.view)
        print(rect)
        //最大值和最小值之间
        layoutConstraint_left.constant = min(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(cropView.bounds), max(layoutConstraint_left.constant, 0))
        layoutConstraint_top.constant = min(CGRectGetHeight(self.view.bounds) - CGRectGetHeight(cropView.bounds), max(layoutConstraint_top.constant, 0))
        layoutConstraint_width.constant = min(self.view.bounds.width, max(layoutConstraint_width.constant, 3 * 40 ))
        layoutConstraint_height.constant = min(self.view.bounds.height, max(layoutConstraint_height.constant, 3 * 40 ))
        
        self.resetCropMask()
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        btnType = .None
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        btnType = .None
    }
}

extension PhotoEditViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.imageHolderView.center = centerOfScrollViewContent()
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageHolderView
    }
    func scrollViewDidZoom(scrollView: UIScrollView)  {
    
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        self.imageHolderView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    func centerOfScrollViewContent() -> CGPoint{
        let offsetX: CGFloat = (scrollView.bounds.width > scrollView.contentSize.width) ? (scrollView.bounds.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY: CGFloat = (scrollView.bounds.height > scrollView.contentSize.height) ? (scrollView.bounds.height - scrollView.contentSize.height) * 0.5 : 0.0
        let actualCenter: CGPoint = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY)
        return actualCenter
    }
}

private extension PhotoEditViewController{
    private func configureViews(){
        self.edgesForExtendedLayout = .None
        self.view.backgroundColor = UIColor.blackColor()
        
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.cropMaskView)
        self.view.addSubview(self.cropView)
        self.view.addSubview(self.blackBgView)
        
        self.consraintsForSubViews()
    }
    // MARK: - views actions
    @objc private func handleDoubleTap(gestrue: UITapGestureRecognizer){
        let touchPoint = gestrue.locationInView(gestrue.view)
        if (scrollView.zoomScale <= 1.0) {
            scrollView.zoomToRect(CGRectMake(touchPoint.x, touchPoint.y , 10, 10), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    @objc private func confirmSelectedImageBtnAction(){
        
        if let block = self.block{
        //获取图片位置
        //相对于 统一坐标系的左边 关于图片的截取 一定要用相对位置去弄 否则 嘿嘿嘿!!!!!!!!!切记 血的教训 并且 第二条法则 一定要乘以 self.scrollView.zoomScale 哈哈哈
        let rect = self.view.convertRect(self.cropView.frame, toView: self.imageHolderView)
            
        let scare_x = rect.origin.x/self.imageHolderView.frame.size.width
        let x = scare_x * (self.imageHolderView.image?.size.width)! * self.scrollView.zoomScale
            
        let scare_y = rect.origin.y/self.imageHolderView.frame.size.height
        let y = scare_y * (self.imageHolderView.image?.size.height)! * self.scrollView.zoomScale
            
        let scare_width = self.cropView.frame.size.width/self.imageHolderView.frame.size.width
        let width = scare_width * (self.imageHolderView.image?.size.width)!
        let scare_height = self.cropView.frame.size.height/self.imageHolderView.frame.size.height
        let height = scare_height * (self.imageHolderView.image?.size.height)!
 
       let theImage = UIImage.getSubImage(self.imageHolderView.image, mCGRect: CGRectMake(x, y,width, height))
            block(image: theImage)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func cancelSelectedImageBtnAction(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - getter and setter
   
    private var scrollView: DemoScrollView {
        get{
            if _scrollView == nil{
                _scrollView = DemoScrollView()
                _scrollView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 100)
                _scrollView.backgroundColor = UIColor.blackColor()
                _scrollView.userInteractionEnabled = true
                _scrollView.delegate = self
                _scrollView.minimumZoomScale = 1
                _scrollView.setZoomScale(1.0, animated: true)
                _scrollView.maximumZoomScale = 2
                _scrollView.delaysContentTouches = false
                _scrollView.canCancelContentTouches = true
                
                _scrollView.addSubview(self.imageHolderView)
                let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PhotoEditViewController.handleDoubleTap(_:)))
                doubleTap.numberOfTapsRequired = 2
                _scrollView.addGestureRecognizer(doubleTap)
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
                _imageHolderView.frame = _scrollView.bounds
                _imageHolderView.clipsToBounds = true
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
                _cropMaskView.frame = self.view.bounds
                _cropMaskView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
                _cropMaskView.userInteractionEnabled = false
              
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
                _cropView.translatesAutoresizingMaskIntoConstraints = false
                
            }
            return _cropView
        }
        set{
            _cropView = newValue
        }
    }
    

    private var blackBgView: UIView {
        get{
            if _blackBgView == nil{
                _blackBgView = UIView()
                _blackBgView.translatesAutoresizingMaskIntoConstraints = false
                _blackBgView.backgroundColor = UIColor.blackColor()
                
                _blackBgView.addSubview(self.cancelSelectedImageBtn)
                _blackBgView.addSubview(self.confirmSelectedImageBtn)
            
                
                //_cancelSelectedImageBtn
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view(==100)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _cancelSelectedImageBtn]))
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==50)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _cancelSelectedImageBtn]))
                
                //_confirmSelectedImageBtn
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==100)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _confirmSelectedImageBtn]))
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==50)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _confirmSelectedImageBtn]))
                
            }
            return _blackBgView
            
        }
        set{
            _blackBgView = newValue
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
                 _cancelSelectedImageBtn.addTarget(self, action: #selector(PhotoEditViewController.cancelSelectedImageBtnAction), forControlEvents: .TouchUpInside)
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
                _confirmSelectedImageBtn.addTarget(self, action: #selector(PhotoEditViewController.confirmSelectedImageBtnAction), forControlEvents: .TouchUpInside)
            }
            return _confirmSelectedImageBtn
            
        }
        set{
            _confirmSelectedImageBtn = newValue
        }
    }

    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        
        //_demoView
        let arr1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[view(\(CGRectGetWidth(self.view.frame) - 100))]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _cropView])
        layoutConstraint_left = arr1.first
        layoutConstraint_width = arr1.last
        self.view.addConstraints(arr1)
        
        let arr2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-50-[view(==150)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _cropView])
        layoutConstraint_top = arr2.first
        layoutConstraint_height = arr2.last
        
        self.view.addConstraints(arr2)
        
        //_blackBgView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _blackBgView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==100)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _blackBgView]))
    }
    
}