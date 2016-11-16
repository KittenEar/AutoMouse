//
//  OpenCV.m
//  AutoMouse
//
//  Created by cat-07 on 2016/01/10.
//  Copyright © 2016年 cat-07. All rights reserved.
//

#import "OpenCV.h"
#import <opencv2/opencv.hpp>

@implementation OpenCV

+ (CGPoint)matching:(NSString *)imageFilename searchImages:(NSArray *)searchImages {

//    cv::Mat src = cv::imread("ss.bmp");
    cv::Mat src = cv::imread([imageFilename UTF8String]);
//    cv::Mat src = cv::imread("src.png");
//    cv::string filename[] = {
//        "cookie00.png", "cookie01.png", "cookie02.png", "cookie03.png",
//        "cookie04.png", "cookie05.png", "cookie06.png", "cookie07.png"
//    };
    
    // NSArray -> cv::string[] 変換
    std::vector<cv::string> searchFilenames;
    
    for (int i = 0; i < searchImages.count; i++) {
        searchFilenames.push_back([searchImages[i] UTF8String]);
    }
    
    
    double score = 0.0;
    cv::Rect roi;
    NSPoint point = CGPointMake(0, 0);
//    cv::Point point;
    
    cv::Mat resize;
    // retina display なので1/2にする. NSScreen@backingScaleFactor で判定できる
    cv::resize(src, resize, cv::Size(), 0.5, 0.5);
    
    for (int i = 0; i < searchImages.count; i++) {
        
        cv::Mat search = cv::imread(searchFilenames[i]);
        cv::Mat dst;

        cv::Rect roiRect;
        cv::Point maxPoint;
        double maxVal;
        
        cv::matchTemplate(resize, search, dst, CV_TM_CCOEFF_NORMED);
//        cv::matchTemplate(src, search, dst, CV_TM_CCORR_NORMED);
        [self match:resize
              templ:search
                dst:&dst
             method:CV_TM_CCOEFF_NORMED
            roiRect:&roiRect
           maxPoint:&maxPoint
             maxVal:&maxVal];
        
//        cv::Rect roi_rect(0, 0, search.cols, search.rows);
//        cv::Point max_pt;
//        double maxVal;
//        cv::minMaxLoc(dst, NULL, &maxVal, NULL, &max_pt);
//        
//        roi_rect.x = max_pt.x;
//        roi_rect.y = max_pt.y;
        
        // 0.7以上でマッチングしたとみなす。必要があれば調整すること
        if (maxVal >= 0.7) {
            score = maxVal;
            roi = roiRect;
            point.x = maxPoint.x;
            point.y = maxPoint.y;
            
            // 探索結果の場所に矩形を描画
            cv::rectangle(resize, roi, cv::Scalar(0,0,255), 5);
//            std::cout << "x " << point.x << ": y " << point.y << std::endl;
            cv::imwrite("dst.png", resize);
        }
        
        std::cout << "(" << maxPoint.x << ", " << maxPoint.y << "), score=" << maxVal << std::endl;
    }
        
    return point;
}

+ (CGPoint)matching:(NSString *)srcFilename
        searchImage:(NSString *)searchFilename
             maxVal:(CGFloat *)maxVal {

    cv::Mat src = cv::imread([srcFilename UTF8String]);
    cv::Mat search = cv::imread([searchFilename UTF8String]);
    cv::Mat dst;
    
    cv::Rect roiRect;
    cv::Point maxPoint;

    [self match:src
          templ:search
            dst:&dst
         method:CV_TM_CCOEFF_NORMED
        roiRect:&roiRect
       maxPoint:&maxPoint
         maxVal:maxVal];
    
    NSPoint point = CGPointMake(maxPoint.x, maxPoint.y);

    return point;
}

+ (void)match:(cv::Mat)src
        templ:(cv::Mat)templ
          dst:(cv::Mat *)dst
       method:(int)method
      roiRect:(cv::Rect *)roiRect
     maxPoint:(cv::Point *)maxPoint
       maxVal:(double *)maxVal {

    cv::Mat workDst;
    cv::Point workMaxPoint;
    double workMaxVal;

    cv::matchTemplate(src, templ, workDst, method);
    
    cv::Rect workRoiRect(0, 0, templ.cols, templ.rows);
    cv::minMaxLoc(workDst, NULL, &workMaxVal, NULL, &workMaxPoint);

    workRoiRect.x = workMaxPoint.x;
    workRoiRect.y = workMaxPoint.y;

    *dst = workDst;
    *roiRect = workRoiRect;
    *maxPoint = workMaxPoint;
    *maxVal = workMaxVal;
    
}


@end
