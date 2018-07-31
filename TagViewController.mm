//
//  TagViewController.m
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 27..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "TagViewController.h"
#import "AppDelegate.h"
#import "LGAlertView.h"
#import "RunModelViewController.h"
#import "PageContentViewController.h"

@interface TagViewController () <LGAlertViewDelegate, PHPhotoLibraryChangeObserver, UIAlertViewDelegate>
@property (assign) CGSize lastImageViewSize;

@end

@implementation TagViewController
@synthesize img_Category;

-(void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex
{
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
  
    //해시태그관련코드
    [_tagList setAutomaticResize:YES];
    [_tagList setTags:_array];
    [_tagList setTagDelegate:self];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!CGSizeEqualToSize(self.hashtagImageView.bounds.size, self.lastImageViewSize)) {
        [self updateImage];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
}

- (void)updateImage
{
    self.lastImageViewSize = self.hashtagImageView.bounds.size;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.hashtagImageView.bounds) * scale, CGRectGetHeight(self.hashtagImageView.bounds) * scale);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result) {
            
            self.hashtagImageView.image = result;
            
            NSData *imgData = UIImageJPEGRepresentation(result, 0.7);
            
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
            [imgData writeToFile:jpgPath atomically:YES];
            
            //checking
            //self.imageView2.image=[UIImage imageWithContentsOfFile:jpgPath];
            
            //전역변수로
            AppDelegate *mAPP = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            mAPP.dimagePath = jpgPath;
            printf("[[[[paht:%s", [mAPP.dimagePath UTF8String]);
            
            _array = RecognitionImage();
            [_array removeLastObject];
            
            if([img_Category isEqualToString: @"human"]){
                [_array addObject:@"#selfie"];
                [_array addObject:@"#ootd"];
            }
            if([img_Category isEqualToString: @"animal"]){
                [_array addObject:@"#pet"];
                [_array addObject:@"#animalstagram"];
                [_array addObject:@"#animalsofinstagram"];
            }
            if([img_Category isEqualToString: @"landscape"]){
                [_array addObject:@"#viewstagram"];
                [_array addObject:@"#viewsofpnw"];
                [_array addObject:@"#daliy"];
            }
            if([img_Category isEqualToString: @"food"]){
                [_array addObject:@"#delicious"];
                [_array addObject:@"#foodstagram"];
            }
            if([img_Category isEqualToString:@"concert"]){
                [_array addObject:@"#live"];
                [_array addObject:@"#gig"];
            }
            
        }
    }];

}
/*
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the album we're interested on (to its metadata, not to its collection of assets)
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.asset];
        if (changeDetails) {
            // it changed, we need to fetch a new one
            self.asset = [changeDetails objectAfterChanges];
            
            if ([changeDetails assetContentChanged]) {
                [self updateImage];
                
            }
        }
        
    });
}
*/
- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //에셋뷰에서 넘어온 이미지 보여주기
 
    //self.hashtagImageView.image = [UIImage imageNamed:_handoverImage];
    
}

/*
// 태그 추가하기
- (IBAction)tappedAdder:(id)sender {
    [_addTagField resignFirstResponder];
    if([[_addTagField text] length]) {
        [_array addObject:[_addTagField text]];
    }
    [_addTagField setText:@""];
    [_tagList setTags:_array];
}
*/

// 공유 버튼을 눌렀을 때 실행
- (IBAction)tappedSharing:(id)sender {
     LGAlertView *alertView = [[LGAlertView alloc]initWithTitle:@"공유하기"
                                                        message:@"태그복사 후 SNS로 공유가 가능합니다"
                                                          style:LGAlertViewStyleAlert
                                                   buttonTitles:@[@"태그복사", @"SNS 업로드"]
                                              cancelButtonTitle:@"cancle"
                                         destructiveButtonTitle:nil
                                                       delegate:self];
    
    alertView.backgroundBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
    alertView.backgroundColor = UIColor.clearColor;
    
    alertView.separatorsColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    
    alertView.tintColor = [UIColor colorWithRed:0.5 green:0.75 blue:1.0 alpha:1.0];
    alertView.buttonsBackgroundColorHighlighted = [alertView.tintColor colorWithAlphaComponent:0.5];
    alertView.cancelButtonBackgroundColorHighlighted = [alertView.tintColor colorWithAlphaComponent:0.5];
    alertView.destructiveButtonTitleColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0];
    alertView.destructiveButtonBackgroundColorHighlighted = [alertView.destructiveButtonTitleColor colorWithAlphaComponent:0.5];
    
    alertView.coverColor = UIColor.clearColor;
    alertView.coverBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    alertView.coverAlpha = 0.5;
   
    
    [alertView showAnimated];
 
}

- (void)alertView:(nonnull LGAlertView *)alertView clickedButtonAtIndex:(NSUInteger)index title:(nullable NSString *)title
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *hasgTagString = [NSString stringWithFormat:@"%@", [app.selectedTextArray componentsJoinedByString:@""]];
    
    if(index == 0) { // 태그 복사하기 버튼
        [[UIPasteboard generalPasteboard] setString:hasgTagString];
    }
    
    if(index == 1) {
        
        NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *saveImagePath = [documentDirectory stringByAppendingPathComponent:@"shareImage.igo"];
        NSData *imageData = UIImagePNGRepresentation(self.hashtagImageView.image);
        [imageData writeToFile:saveImagePath atomically:YES];
        NSURL *imageURL1 = [NSURL fileURLWithPath:saveImagePath];
        
        NSString *documentDirectory2 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *saveImagePath2 = [documentDirectory2 stringByAppendingPathComponent:@"shareImage.jpg"];
        NSData *imageData2 = UIImagePNGRepresentation(self.hashtagImageView.image);
        [imageData2 writeToFile:saveImagePath2 atomically:YES];
        NSURL *imageURL2 = [NSURL fileURLWithPath:saveImagePath2];
        
        
        NSArray *activityItems;
        
        //activityItems = @[image.image, imageURL];
        activityItems = @[imageURL1, imageURL2];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:activityItems
                                                        applicationActivities:nil];
        
        [self presentViewController:activityController animated:YES completion:nil];
        
    }
}



@end
