//
//  PageViewController.m
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 26..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController

/*
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
      _pageImages = (NSMutableArray *)_gridViewController.assetsFetchResults;
    self.dataSource = self;
    
    AssetViewController *initialVC = (AssetViewController *)[self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialVC];
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
}

-(UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    AssetViewController *assetViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AssetViewController"];
    assetViewController.strImage = _pageImages[index];
    assetViewController.pageIndex = index;
    
    return assetViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((AssetViewController *)viewController).pageIndex;
    if (index == 0 || index == NSNotFound) {
        return  nil;
    }
    index--;
    
    
    return [self viewControllerAtIndex:index];
    
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((AssetViewController *)viewController).pageIndex;
    if(index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == _pageImages.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
    
}
*/

@end
