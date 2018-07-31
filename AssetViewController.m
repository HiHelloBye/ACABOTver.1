//
//  AssetViewController.m
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 22..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "AssetViewController.h"
#import "GridViewController.h"


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

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UITextView *result;
@property (assign) CGSize lastImageViewSize;

@end

@implementation AssetViewController

//static NSString * const AdjustmentFormatIdentifier = @"com.example.apple-samplecode.SamplePhotosApp";
static NSString * const AdjustmentFormatIdentifier = @"Google.RunModel.jk";

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self updateImage];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!CGSizeEqualToSize(self.imageView.bounds.size, self.lastImageViewSize)) {
        [self updateImage];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
}

-(void)updateImage {
    self.lastImageViewSize = self.imageView.bounds.size;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.imageView.bounds) * scale, CGRectGetHeight(self.imageView.bounds) * scale);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result) {
            self.imageView.image = result;
            
            // Convert UIImage to JPEG and save at document folder
            NSData *imgData = UIImageJPEGRepresentation(self.imageView.image, 1);
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
            [imgData writeToFile:jpgPath atomically:YES];
            
            //checking
            //self.imageView2.image=[UIImage imageWithContentsOfFile:jpgPath];
            
            //전역변수로
            AppDelegate *mAPP = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            mAPP.dimagePath = jpgPath;
            printf("[[[[paht:%s", [mAPP.dimagePath UTF8String]);
        }
    }];
}

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
                [self updateImage];

            }
        }
        
    });
}

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
    /*
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
     }*/
}
@end
