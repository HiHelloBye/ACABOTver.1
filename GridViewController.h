//
//  GridViewController.h
//  tf_ios_makefile_example
//
//  Created by SWUCOMPUTER on 2017. 5. 22..
//  Copyright © 2017년 Google. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <Photos/Photos.h>

@interface GridViewController : UICollectionViewController


@property (strong) PHFetchResult     *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;

@property (weak, nonatomic)   IBOutlet UIBarButtonItem *selectionButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cassifyButton;

//@property (strong, nonatomic) NSMutableArray *all_photo;
@property (strong, nonatomic) NSMutableArray *not_classified_photo;
@property (assign, nonatomic) NSInteger      all_or_collection;
//all photo = 0, 정리할 앨범= 1, 그 외 = 2;  콜렉션뷰 셀 출력시 저장할때 구분해야 함


@property (strong, nonatomic) NSMutableArray *core_photo; //CoreData에서 fetch한 데이터 담을 배열
@property (strong, nonatomic) NSMutableArray *identifiers; //identifier string배열

@property (strong, nonatomic) NSString *imgCategory;

- (IBAction)classifyButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)selectionButtonPressed:(id)sender;

@end
