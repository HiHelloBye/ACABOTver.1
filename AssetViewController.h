//
//  AssetViewController.h
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 22..
//  Copyright © 2017년 Google. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PageContentViewController.h"
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface AssetViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong) PHAsset *asset;
@property (strong) PHAssetCollection *assetCollection;
@property (strong) PHFetchResult     *assetsFetchResults;
@property (weak, nonatomic) IBOutlet UIImageView *testImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *hasgtagButton;

@property NSInteger  section; // 그리드 뷰 컨트롤러에서 선택된 섹션을 알기 위해 선언
@property NSUInteger handoverPageIndex; //해시태그뷰에 넘겨줄 사진 배열 방번호를 알려주기 위해 선언

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *pageImages; // 페이지 컨트롤러 뷰로 볼 모든 이미들

@property (assign, nonatomic) NSInteger all_or_collection;

@property (strong, nonatomic) NSString *img_Category;
//all photo = 0, 정리할 앨범= 1, 그 외 = 2;
- (IBAction)hashtagButtonSelected:(UIBarButtonItem *)sender;

@end
