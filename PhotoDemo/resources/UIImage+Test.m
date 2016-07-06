//
//  UIImage+Test.m
//  PhotoDemo
//
//  Created by WeiHu on 7/6/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import "UIImage+Test.h"

@implementation UIImage (Test)
+ (UIImage *)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect
{
    
    /*如若centerBool为Yes则是由中心点取mCGRect范围的图片*/
    
    
    float imgwidth = image.size.width;
    float imgheight = image.size.height;
    float viewwidth = mCGRect.size.width;
    float viewheight = mCGRect.size.height;
//    CGRect rect;
//
//    if (viewheight < viewwidth) {
//        if (imgwidth <= imgheight) {
//            rect = CGRectMake(0, 0, imgwidth, imgwidth*viewheight/viewwidth);
//        }else {
//            float width = viewwidth*imgheight/viewheight;
//            float x = (imgwidth - width)/2 ;
//            if (x > 0) {
//                rect = CGRectMake(x, 0, width, imgheight);
//            }else {
//                rect = CGRectMake(0, 0, imgwidth, imgwidth*viewheight/viewwidth);
//            }
//        }
//    }else {
//        if (imgwidth <= imgheight) {
//            float height = viewheight*imgwidth/viewwidth;
//            if (height < imgheight) {
//                rect = CGRectMake(0, 0, imgwidth, height);
//            }else {
//                rect = CGRectMake(0, 0, viewwidth*imgheight/viewheight, imgheight);
//            }
//        }else {
//            float width = viewwidth*imgheight/viewheight;
//            if (width < imgwidth) {
//                float x = (imgwidth - width)/2 ;
//                rect = CGRectMake(x, 0, width, imgheight);
//            }else {
//                rect = CGRectMake(0, 0, imgwidth, imgheight);
//            }
//        }
//    }

    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, mCGRect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}
@end
