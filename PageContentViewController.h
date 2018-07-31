//
//  PageContentViewController.h
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 27..
//  Copyright © 2017년 Google. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "AppDelegate.h"
#import "RunModelViewController.h"

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;

@property (strong) PHAsset *receiveImage;
//@property UIImage* receiveImage;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@property (strong) PHAssetCollection *assetCollection;
@property (strong) PHFetchResult     *assetsFetchResults;

@property (assign, nonatomic) NSInteger all_or_collection;
//all photo = 0, 정리할 앨범= 1, 그 외 = 2;
@property (strong, nonatomic) NSMutableArray *core_photo; //CoreData에서 fetch한 데이터 담을 배열

@property NSInteger  section;
@property (strong, nonatomic) NSString *img_Category;

- (IBAction)trashButtonPressed:(UIBarButtonItem *)sender;
- (void)updateImage;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *hashTag;
@end
