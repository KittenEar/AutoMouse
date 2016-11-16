//
//  OpenCV.h
//  AutoMouse
//
//  Created by cat-07 on 2016/01/10.
//  Copyright © 2016年 cat-07. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenCV : NSObject

+ (CGPoint)matching:(NSString *)imageFilename searchImages:(NSArray *)searchImages;

+ (CGPoint)matching:(NSString *)srcFilename
        searchImage:(NSString *)searchFilename
             maxVal:(CGFloat *)maxVal;

@end
