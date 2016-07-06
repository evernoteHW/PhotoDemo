//
//  UIImage+Test.h
//  PhotoDemo
//
//  Created by WeiHu on 7/6/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Test)
+ (UIImage *)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect;
@end
