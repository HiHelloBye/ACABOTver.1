//
//  PageViewController.h
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 26..
//  Copyright © 2017년 Google. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetViewController.h"
#import "GridViewController.h"

@interface PageViewController : UIPageViewController <UIPageViewControllerDataSource>

@property NSArray *pageImages;
@property (strong, nonatomic) PageViewController *pageViewController;
@property (strong, nonatomic) AssetViewController *assetViewController;
@property (strong, nonatomic) GridViewController *gridViewController;

@end
