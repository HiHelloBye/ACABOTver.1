//
//  AssetViewController.m
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 22..
//  Copyright © 2017년 Google. All rights reserved.
//

#import  "PageContentViewController.h"
#import  "AssetViewController.h"
#import  "GridViewController.h"
#include "RunModelViewController.h"
#include "RootListViewController.h"
#include "TagViewController.h"

@implementation CIImage (Convenience)

- (NSData *)aapl_jpegRepresentationWithCompressionQuality:(CGFloat)compressionQuality {
    static CIContext *ciContext = nil;
    if (!ciContext) {
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        ciContext = [CIContext contextWithEAGLContext:eaglContext];
    }
    CGImageRef outputImageRef = [ciContext createCGImage:self fromRect:[self extent]];
    UIImage *uiImage = [[UIImage alloc] initWithCGImage:outputImageRef scale:1.0 orientation:UIImageOrientationUp];
    if (outputImageRef) {
        CGImageRelease(outputImageRef);
    }
    NSData *jpegRepresentation = UIImageJPEGRepresentation(uiImage, compressionQuality);
    return jpegRepresentation;
}

@end


@interface AssetViewController () <PHPhotoLibraryChangeObserver>

@property (assign) CGSize lastImageViewSize;
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation AssetViewController
@synthesize pageImages;
@synthesize img_Category;

//static NSString * const AdjustmentFormatIdentifier = @"com.example.apple-samplecode.SamplePhotosApp";
static NSString * const AdjustmentFormatIdentifier = @"Google.RunModel.jk";

-(void)awakeFromNib {
    [super awakeFromNib];
    
    
}
-(void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    //[self updateImage];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
   
    /*
    if (!CGSizeEqualToSize(self.imageView.bounds.size, self.lastImageViewSize)) {
        //[self updateImage];
    }
     */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
 }

-(void)viewDidAppear:(BOOL)animated {
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:_section];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // 페이지 뷰 컨트롤러 사이즈 변경하기
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 30);
    
    [self addChildViewController: self.pageViewController];
    [self.view addSubview: self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

// 보여지는 사진 그 전 사진이 있는지 판단
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    _handoverPageIndex = index;
    _section = index;
    
    return [self viewControllerAtIndex:index];
}
// 보여지는 사진 그 후 사진이 있는지 판단
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == [self.assetsFetchResults count]) {
        return nil;
    }
    _handoverPageIndex = index;
    _section = index;
    return [self viewControllerAtIndex:index];
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];

    pageContentViewController.receiveImage = self.assetsFetchResults[index];
    pageContentViewController.pageIndex = index;
    pageContentViewController.assetCollection = self.assetCollection;
    pageContentViewController.all_or_collection = self.all_or_collection;
    pageContentViewController.section = self.section;
    pageContentViewController.assetsFetchResults = self.assetsFetchResults;
    pageContentViewController.img_Category = self.img_Category;
    _handoverPageIndex = index;
    _section = index;

    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.assetsFetchResults count];
}
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


/*
-(void)updateImage {
    
    //self.lastImageViewSize = self.imageView.bounds.size;
    PageContentViewController *pageContentViewController;
    self.lastImageViewSize = pageContentViewController.ImageView.bounds.size;
    
    __block NSString *tensor;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(pageContentViewController.ImageView.bounds) * scale, CGRectGetHeight(pageContentViewController.ImageView.bounds) * scale);
    
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result) {
            //self.imageView.image = result;
            /*
            // Convert UIImage to JPEG and save at document folder
            NSData *imgData = UIImageJPEGRepresentation(pageContentViewController.ImageView.image, 1);
            //imgdata 작게 만들기
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
            [imgData writeToFile:jpgPath atomically:YES];
            */
            
            //전역변수로
            /*
            AppDelegate *mAPP = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            mAPP.dimagePath = jpgPath;
            printf("[[[[paht:%s", [mAPP.dimagePath UTF8String]);
            
            tensor = RunInferenceOnImage();
            
            printf("\n\n\n[[[[%s \n", [tensor UTF8String]);
            
        }
    }];
}*/

-(void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the album we're interested on (to its metadata, not to its collection of assets)
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.asset];
        if (changeDetails) {
            // it changed, we need to fetch a new one
            self.asset = [changeDetails objectAfterChanges];
            
            if ([changeDetails assetContentChanged]) {
                PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
                [pageContentViewController updateImage];

            }
        }
        
    });
}
/*
- (void)setResult:(UITextField *)result{
    
    NSString *localIdentifier = nil;
    
    NSString *url1 = @"assets-library://asset/asset.JPG?id=";
    NSString *url2 = @"&ext=JPG";
    NSString *identi = nil;
    NSString *url = nil;
    
    //printf("%s", [localIdentifier UTF8String]);
    
    localIdentifier = self.asset.localIdentifier;
    identi = [localIdentifier substringToIndex:36];
    
    url = [url1 stringByAppendingString:identi];
    url = [url stringByAppendingString:url2];
    
    //printf("<<%s>>", [url UTF8String]);
    
    //result.text =@"URL: ";
    //result.text = [NSString stringWithFormat:@"%s",[url UTF8String]];
 
     //url -> path
     if (self.asset) {
     // get photo info from this asset
     PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
     imageRequestOptions.synchronous = YES;
     [[PHImageManager defaultManager]
     requestImageDataForAsset:self.asset
     options:imageRequestOptions
     resultHandler:^(NSData *imageData, NSString *dataUTI,
     UIImageOrientation orientation,
     NSDictionary *info)
     {
     NSLog(@"info = %@", info);
     if ([info objectForKey:@"PHImageFileURLKey"]) {
     // path looks like this -
     // file:///var/mobile/Media/DCIM/###APPLE/IMG_####.JPG
     NSURL *path = [info objectForKey:@"PHImageFileURLKey"];
     NSString *pathstring = path.absoluteString;
     result.text = [NSString stringWithFormat:@"url: %s\n\npath: %s",[url UTF8String], [pathstring UTF8String]];
     [self.view endEditing:YES];
     }
     }];
     }
}
*/
@end
