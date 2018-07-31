//
//  TagViewController.h
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 27..
//  Copyright © 2017년 Google. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagList.h"
#import <Photos/Photos.h>
#import <Social/Social.h>


@interface TagViewController : UIViewController <TagListDelegate>

@property PHAsset *asset;  //에셋뷰에서 이미지 값을 받기위해 선언

@property (weak, nonatomic) IBOutlet UIImageView *hashtagImageView;

@property (nonatomic, strong) NSMutableArray     *array;
@property (nonatomic, weak) IBOutlet TagList     *tagList; // 해시태그 목록들
@property (weak, nonatomic) IBOutlet UITextField *addTagField;

@property (strong, nonatomic) NSString *img_Category;

- (IBAction)tappedAdder:(id)sender;
- (IBAction)tappedSharing:(id)sender;

@end
