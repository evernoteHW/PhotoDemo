
//
//  PhotoEditViewController.swift
//  PhotoDemo
//
//  Created by WeiHu on 7/1/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

typealias SelecteImageBlock = (image:UIImage)->Void

class PhotoEditViewController: UIViewController {
    /// public
    var startPoint: UnsafeMutablePointer<CGPoint> = UnsafeMutablePointer<CGPoint>.alloc(1)
    
    //记录透明区域移动的起始位置
    var startPointCropView: CGPoint = CGPointZero
    
    //存储不同缩放比例示意图的图片名
    var proportionImageNameArr = ["crop_free", "crop_1_1", "crop_4_3", "crop_3_4", "crop_16_9", "crop_9_16"]
    //存储不同缩放比例示意图的高亮图片名
    var proportionImageNameHLArr = ["cropHL_free", "cropHL_1_1", "cropHL_4_3", "cropHL_3_4", "cropHL_16_9", "cropHL_9_16"]
    var block: SelecteImageBlock?
    
    var oringinImage: UIImage?
    /// private
    private var _blackBgView: UIView!
    private var _cancelSelectedImageBtn: UIButton!
    private var _confirmSelectedImageBtn: UIButton!
    private var _testImageView: UIImageView!
    
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
    private var _arrow5: UIImageView!
    private var _arrow6: UIImageView!
    private var _arrow7: UIImageView!
    private var _arrow8: UIImageView!
    
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
//        self.cropView.layer.borderWidth = CROPVIEWBORDERWIDTH;
//        self.cropView.layer.borderColor = UIColor.whiteColor().CGColor;
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
        
        let frame = self.imageHolderView.frame
        self.imageHolderView.image = self.oringinImage;

        let imageSize = self.imageHolderView.image!.size;//获得图片的size
        var imageFrame = CGRectMake(0, 0,imageSize.width, imageSize.height);

        let ratio = frame.size.width/imageFrame.size.width;
        imageFrame.size.height = imageFrame.size.height*ratio;
        imageFrame.size.width = frame.size.width;
        
        self.imageHolderView.frame = imageFrame;
        self.scrollView.contentSize = self.imageHolderView.frame.size;
        self.imageHolderView.center = self.centerOfScrollViewContent()
    
        //根据图片大小找到最大缩放等级，保证最大缩放时候，不会有黑边
        var maxScale: CGFloat = frame.size.height/imageFrame.size.height;
        maxScale = (frame.size.width/imageFrame.size.width>maxScale) ? (frame.size.width/imageFrame.size.width) : maxScale
        //超过了设置的最大的才算数
        maxScale = max(maxScale, 2.0)
        //初始化
        self.scrollView.maximumZoomScale = maxScale;

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
        let maxX = CGRectGetMaxX(self.scrollView.frame) - CGRectGetWidth(self.cropView.frame);
        let minY = CGRectGetMinY(self.imageHolderView.frame);
        let maxY = CGRectGetMaxY(self.imageHolderView.frame) - CGRectGetHeight(self.cropView.frame);
        
        if(panGesture.state == .Began) {
            startPointCropView = panGesture.locationInView(self.cropMaskView)
            self.arrow1.userInteractionEnabled = false;
            self.arrow2.userInteractionEnabled = false;
            self.arrow3.userInteractionEnabled = false;
            self.arrow4.userInteractionEnabled = false;
            
            self.arrow5.userInteractionEnabled = false;
            self.arrow6.userInteractionEnabled = false;
            self.arrow7.userInteractionEnabled = false;
            self.arrow8.userInteractionEnabled = false;
        }
        else if(panGesture.state == .Ended) {
            self.arrow1.userInteractionEnabled = true;
            self.arrow2.userInteractionEnabled = true;
            self.arrow3.userInteractionEnabled = true;
            self.arrow4.userInteractionEnabled = true;
            
            self.arrow5.userInteractionEnabled = true;
            self.arrow6.userInteractionEnabled = true;
            self.arrow7.userInteractionEnabled = true;
            self.arrow8.userInteractionEnabled = true;
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
            case self.arrow1:
                maxY = CGRectGetMinY(self.arrow3.frame) - ARROWHEIGHT - ARROWMINIMUMSPACE;
                maxX = CGRectGetMinX(self.arrow2.frame) - ARROWWIDTH - ARROWMINIMUMSPACE;
            case self.arrow2:
                maxY = CGRectGetMinY(self.arrow4.frame) - ARROWHEIGHT - ARROWMINIMUMSPACE;
                minX = CGRectGetMaxX(self.arrow1.frame) + ARROWMINIMUMSPACE;
            case self.arrow3:
                minY = CGRectGetMaxY(self.arrow1.frame) + ARROWMINIMUMSPACE;
                maxX = CGRectGetMinX(self.arrow4.frame) - ARROWWIDTH - ARROWMINIMUMSPACE;
            case self.arrow4:
                minY = CGRectGetMaxY(self.arrow2.frame) + ARROWMINIMUMSPACE;
                minX = CGRectGetMaxX(self.arrow3.frame) + ARROWMINIMUMSPACE;
            case self.arrow5:
                maxX = self.arrow7.frame.origin.x - 25
                
                minY = panGesture.view!.frame.origin.y
                maxY = panGesture.view!.frame.origin.y
            case self.arrow6:

                minX = panGesture.view!.frame.origin.x
                maxX = panGesture.view!.frame.origin.x
            
                minY = CGRectGetMaxY(self.arrow8.frame)
            
            case self.arrow7:
                minX = CGRectGetMaxX(self.arrow5.frame)
                
                minY = panGesture.view!.frame.origin.y
                maxY = panGesture.view!.frame.origin.y
            
            case self.arrow8:
                minX = panGesture.view!.frame.origin.x
                maxX = panGesture.view!.frame.origin.x
            
                maxY = CGRectGetMinY(self.arrow6.frame) - 22
            
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
                
                //移动的距离
                frame.origin.x += endPoint.x - startPoint.memory.x
                frame.origin.y += endPoint.y - startPoint.memory.y
                frame.origin.x = min(maxX, max(frame.origin.x, minX));
                frame.origin.y = min(maxY, max(frame.origin.y, minY));
                print(frame)
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
        switch arrow {
            case self.arrow1:
                self.arrow2.center = CGPointMake(self.arrow2.center.x, self.arrow1.center.y);
                self.arrow3.center = CGPointMake(self.arrow1.center.x, self.arrow3.center.y);
            
                self.arrow5.center = CGPointMake(self.arrow1.center.x, self.cropView.center.y);
                self.arrow6.center = CGPointMake(self.cropView.center.x, self.arrow3.center.y);
                self.arrow7.center = CGPointMake(self.arrow2.center.x, self.cropView.center.y);
                self.arrow8.center = CGPointMake(self.cropView.center.x, self.arrow1.center.y);
            
            case self.arrow2:
                self.arrow1.center = CGPointMake(self.arrow1.center.x, self.arrow2.center.y);
                self.arrow4.center = CGPointMake(self.arrow2.center.x, self.arrow4.center.y);
            
                self.arrow5.center = CGPointMake(self.arrow1.center.x, self.cropView.center.y);
                self.arrow6.center = CGPointMake(self.cropView.center.x, self.arrow3.center.y);
                self.arrow7.center = CGPointMake(self.arrow2.center.x, self.cropView.center.y);
                self.arrow8.center = CGPointMake(self.cropView.center.x, self.arrow1.center.y);
            case self.arrow3:
                self.arrow1.center = CGPointMake(self.arrow3.center.x, self.arrow1.center.y);
                self.arrow4.center = CGPointMake(self.arrow4.center.x, self.arrow3.center.y);
            
                self.arrow5.center = CGPointMake(self.arrow1.center.x, self.cropView.center.y);
                self.arrow6.center = CGPointMake(self.cropView.center.x, self.arrow3.center.y);
                self.arrow7.center = CGPointMake(self.arrow2.center.x, self.cropView.center.y);
                self.arrow8.center = CGPointMake(self.cropView.center.x, self.arrow1.center.y);
        case self.arrow4:
                self.arrow2.center = CGPointMake(self.arrow4.center.x, self.arrow2.center.y);
                self.arrow3.center = CGPointMake(self.arrow3.center.x, self.arrow4.center.y);
            
                self.arrow5.center = CGPointMake(self.arrow1.center.x, self.cropView.center.y);
                self.arrow6.center = CGPointMake(self.cropView.center.x, self.arrow3.center.y);
                self.arrow7.center = CGPointMake(self.arrow2.center.x, self.cropView.center.y);
                self.arrow8.center = CGPointMake(self.cropView.center.x, self.arrow1.center.y);
            case self.arrow5:
                self.arrow1.center = CGPointMake(self.arrow5.center.x, self.arrow1.center.y);
                self.arrow3.center = CGPointMake(self.arrow5.center.x, self.arrow3.center.y);
                
                self.arrow6.center = CGPointMake(self.cropView.center.x, self.arrow3.center.y);
                self.arrow8.center = CGPointMake(self.cropView.center.x, self.arrow2.center.y);
            case self.arrow6:
                self.arrow3.center = CGPointMake(self.arrow3.center.x , self.arrow6.center.y );
                self.arrow4.center = CGPointMake(self.arrow4.center.x , self.arrow6.center.y);
                
                self.arrow5.center = CGPointMake(self.arrow1.center.x, self.cropView.center.y);
                self.arrow7.center = CGPointMake(self.arrow2.center.x, self.cropView.center.y);

            case self.arrow7:
                self.arrow2.center = CGPointMake(self.arrow7.center.x , self.arrow1.center.y);
                self.arrow4.center = CGPointMake(self.arrow7.center.x, self.arrow3.center.y);
                
                self.arrow6.center = CGPointMake(self.cropView.center.x, self.arrow3.center.y);
                self.arrow8.center = CGPointMake(self.cropView.center.x, self.arrow2.center.y);
            case self.arrow8:
                self.arrow1.center = CGPointMake(self.arrow1.center.x, self.arrow8.center.y );
                self.arrow2.center = CGPointMake(self.arrow2.center.x, self.arrow8.center.y );
                
                self.arrow5.center = CGPointMake(self.arrow1.center.x, self.cropView.center.y);
                self.arrow7.center = CGPointMake(self.arrow2.center.x, self.cropView.center.y);

        default:
            break
        }
     

    }
    private func resetAllArrows() {
        self.arrow1.center = CGPointMake(CGRectGetMinX(self.cropView.frame) - ARROWBORDERWIDTH + ARROWWIDTH/2.0, CGRectGetMinY(self.cropView.frame) - ARROWBORDERWIDTH + ARROWHEIGHT/2.0);
        self.arrow2.center = CGPointMake(CGRectGetMaxX(self.cropView.frame) + ARROWBORDERWIDTH - ARROWWIDTH/2.0, CGRectGetMinY(self.cropView.frame) - ARROWBORDERWIDTH + ARROWHEIGHT/2.0);
        self.arrow3.center = CGPointMake(CGRectGetMinX(self.cropView.frame) - ARROWBORDERWIDTH + ARROWWIDTH/2.0, CGRectGetMaxY(self.cropView.frame) + ARROWBORDERWIDTH - ARROWHEIGHT/2.0);
        self.arrow4.center = CGPointMake(CGRectGetMaxX(self.cropView.frame) + ARROWBORDERWIDTH - ARROWWIDTH/2.0, CGRectGetMaxY(self.cropView.frame) + ARROWBORDERWIDTH - ARROWHEIGHT/2.0);
        self.arrow5.center = CGPointMake(self.arrow1.center.x, self.cropView.center.y);
        self.arrow6.center = CGPointMake(self.cropView.center.x,self.arrow3.center.y);
        self.arrow7.center = CGPointMake(self.arrow2.center.x, self.cropView.center.y);
        self.arrow8.center = CGPointMake(self.cropView.center.x, self.arrow2.center.y);
        
        self.view.layoutIfNeeded()
    }
    func resetCropView() {
       self.cropView.frame = CGRectMake(CGRectGetMinX(self.arrow1.frame) + ARROWBORDERWIDTH, CGRectGetMinY(self.arrow1.frame) + ARROWBORDERWIDTH, CGRectGetMaxX(self.arrow2.frame) - CGRectGetMinX(self.arrow1.frame) - ARROWBORDERWIDTH * 2, CGRectGetMaxY(self.arrow3.frame) - CGRectGetMinY(self.arrow1.frame) - ARROWBORDERWIDTH * 2);
    }

    private func clickProportionBtn()  {
    
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
    
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        self.imageHolderView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY);
    }
    
    func centerOfScrollViewContent() -> CGPoint{
        let offsetX: CGFloat = (scrollView.bounds.width > scrollView.contentSize.width) ? (scrollView.bounds.width - scrollView.contentSize.width) * 0.5 : 0.0;
        let offsetY: CGFloat = (scrollView.bounds.height > scrollView.contentSize.height) ? (scrollView.bounds.height - scrollView.contentSize.height) * 0.5 : 0.0;
        let actualCenter: CGPoint = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY);
        return actualCenter;
    }
}
private extension PhotoEditViewController{
    private func configureViews(){
        self.edgesForExtendedLayout = .None
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.cropMaskView)
        self.view.addSubview(self.cropView)
        self.view.addSubview(self.blackBgView)
        self.view.addSubview(arrow1)
        self.view.addSubview(arrow2)
        self.view.addSubview(arrow3)
        self.view.addSubview(arrow4)
        self.view.addSubview(arrow5)
        self.view.addSubview(arrow6)
        self.view.addSubview(arrow7)
        self.view.addSubview(arrow8)
        
        self.consraintsForSubViews();
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
            let image = self.imageFromView(self.view, atFrame: CGRectMake(self.cropView.frame.origin.x + 2, self.cropView.frame.origin.y + 2, self.cropView.frame.size.width - 4, self.cropView.frame.size.height - 4))
            block(image: image)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func cancelSelectedImageBtnAction(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - getter and setter
   
    private var scrollView: UIScrollView {
        get{
            if _scrollView == nil{
                _scrollView = UIScrollView()
                _scrollView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 64)
                _scrollView.backgroundColor = UIColor.orangeColor()
                _scrollView.userInteractionEnabled = true
                _scrollView.delegate = self
                _scrollView.minimumZoomScale = 1
                _scrollView.setZoomScale(1.0, animated: true)
                _scrollView.maximumZoomScale = 2
                
                _scrollView.addSubview(self.imageHolderView)
                let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PhotoEditViewController.handleDoubleTap(_:)))
                doubleTap.numberOfTapsRequired = 2;
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
    
    private var arrow5: UIImageView {
        get{
            if _arrow5 == nil{
                _arrow5 = UIImageView()
                _arrow5.frame = CGRectMake(0, 0, 25, 22)
                _arrow5.backgroundColor = UIColor.clearColor()
                _arrow5.contentMode = .ScaleAspectFit
                _arrow5.userInteractionEnabled = true
                
                let pan = UIPanGestureRecognizer(target: self ,action: #selector(PhotoEditViewController.moveCorner(_:)))
                _arrow5.addGestureRecognizer(pan)
            }
            return _arrow5
            
        }
        set{
            _arrow5 = newValue
        }
    }
    private var arrow6: UIImageView {
        get{
            if _arrow6 == nil{
                _arrow6 = UIImageView()
                _arrow6.frame = CGRectMake(0, 0, 25, 22)
                _arrow6.backgroundColor = UIColor.clearColor()
                _arrow6.contentMode = .ScaleAspectFit
                _arrow6.userInteractionEnabled = true
                
                let pan = UIPanGestureRecognizer(target: self ,action: #selector(PhotoEditViewController.moveCorner(_:)))
                _arrow6.addGestureRecognizer(pan)
            }
            return _arrow6
            
        }
        set{
            _arrow6 = newValue
        }
    }
    private var arrow7: UIImageView {
        get{
            if _arrow7 == nil{
                _arrow7 = UIImageView()
                _arrow7.frame = CGRectMake(0, 0, 25, 22)
                _arrow7.backgroundColor = UIColor.clearColor()
                _arrow7.contentMode = .ScaleAspectFit
                _arrow7.userInteractionEnabled = true
                let pan = UIPanGestureRecognizer(target: self ,action: #selector(PhotoEditViewController.moveCorner(_:)))
                _arrow7.addGestureRecognizer(pan)
            }
            return _arrow7
            
        }
        set{
            _arrow7 = newValue
        }
    }
    private var arrow8: UIImageView {
        get{
            if _arrow8 == nil{
                _arrow8 = UIImageView()
                _arrow8.frame = CGRectMake(0, 0, 25, 22)
                _arrow8.backgroundColor = UIColor.clearColor()
        
                _arrow8.contentMode = .ScaleAspectFit
                _arrow8.userInteractionEnabled = true
                
                let pan = UIPanGestureRecognizer(target: self ,action: #selector(PhotoEditViewController.moveCorner(_:)))
                _arrow8.addGestureRecognizer(pan)
            }
            return _arrow8
            
        }
        set{
            _arrow8 = newValue
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
    
                _blackBgView.addSubview(self.testImageView)
                
                //_cancelSelectedImageBtn
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view(==100)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _cancelSelectedImageBtn]));
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==50)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _cancelSelectedImageBtn]))
                
                //_testImageView
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-100-[view(==80)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _testImageView]));
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==80)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _testImageView]))
                
                //_confirmSelectedImageBtn
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==100)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _confirmSelectedImageBtn]));
                _blackBgView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==50)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _confirmSelectedImageBtn]))
                
            }
            return _blackBgView
            
        }
        set{
            _blackBgView = newValue
        }
    }
    
    private var testImageView: UIImageView {
        get{
            if _testImageView == nil{
                _testImageView = UIImageView()
                _testImageView.translatesAutoresizingMaskIntoConstraints = false
                _testImageView.backgroundColor = UIColor.greenColor()
                _testImageView.contentMode = .ScaleAspectFit
            }
            return _testImageView
            
        }
        set{
            _testImageView = newValue
        }
    }
    
    private var cancelSelectedImageBtn: UIButton {
        get{
            if _cancelSelectedImageBtn == nil{
                _cancelSelectedImageBtn = UIButton()
                _cancelSelectedImageBtn.translatesAutoresizingMaskIntoConstraints = false
                _cancelSelectedImageBtn.backgroundColor = UIColor.orangeColor()
                _cancelSelectedImageBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                _cancelSelectedImageBtn.setTitle("取消", forState: .Normal)
                _cancelSelectedImageBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
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
                _confirmSelectedImageBtn.backgroundColor = UIColor.yellowColor()
                _confirmSelectedImageBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                _confirmSelectedImageBtn.setTitle("确定", forState: .Normal)
                _confirmSelectedImageBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
                _confirmSelectedImageBtn.addTarget(self, action: #selector(PhotoEditViewController.confirmSelectedImageBtnAction), forControlEvents: .TouchUpInside)
            }
            return _confirmSelectedImageBtn
            
        }
        set{
            _confirmSelectedImageBtn = newValue
        }
    }

    
    func imageFromView(theView: UIView, atFrame: CGRect) -> UIImage {
        var theImage: UIImage?
        autoreleasepool {
            UIGraphicsBeginImageContext(theView.frame.size);
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            UIRectClip(atFrame);
            theView.layer.renderInContext(context!)
            theImage = UIGraphicsGetImageFromCurrentImageContext();
            let refImage = CGImageCreateWithImageInRect(theImage!.CGImage, atFrame)
            theImage = UIImage(CGImage: refImage!)
            UIGraphicsEndImageContext();
        }
        
        return  theImage!
    }
    // MARK: - consraintsForSubViews
    private func consraintsForSubViews() {
        //_blackBgView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _blackBgView]));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==100)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": _blackBgView]))
    }
    
}