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
