//
//  PageContentViewController.m
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 27..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "PageContentViewController.h"
#import "TagViewController.h"
#import "GridViewController.h"
#import <CoreData/CoreData.h>

@interface PageContentViewController () <PHPhotoLibraryChangeObserver>

@property (assign) CGSize lastImageViewSize;

@end

@implementation PageContentViewController

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    if( self.all_or_collection == 0 | self.all_or_collection == 1 ) {
        self.hashTag.enabled = NO;
        self.hashTag.tintColor = [UIColor clearColor];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
    [self updateImage];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
   if (!CGSizeEqualToSize(self.ImageView.bounds.size, self.lastImageViewSize)) {
        [self updateImage];
    }
}

- (void)updateImage
{
    self.lastImageViewSize = self.ImageView.bounds.size;

    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.ImageView.bounds) * scale, CGRectGetHeight(self.ImageView.bounds) * scale);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];

    [[PHImageManager defaultManager] requestImageForAsset:self.receiveImage targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result) {
            self.ImageView.image = result;
        }
    }];
    
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the album we're interested on (to its metadata, not to its collection of assets)
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.receiveImage];
        if (changeDetails) {
            // it changed, we need to fetch a new one
            self.receiveImage = [changeDetails objectAfterChanges];
            
            if ([changeDetails assetContentChanged]) {
                [self updateImage];
                
            }
        }
        
    });
}


- (IBAction)trashButtonPressed:(UIBarButtonItem *)sender {
    
    void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        if (success) {
            
            if (self.all_or_collection == 2) { //이미 분류한 사진인 경우 코어데이터에서 삭제
                
                NSString *localIdentifier = self.receiveImage.localIdentifier;
                
                NSManagedObjectContext *context = nil;
                id delegate = [[UIApplication sharedApplication] delegate];
                
                if ([delegate performSelector:@selector(managedObjectContext)]) {
                    context = [delegate managedObjectContext];
                }
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
                self.core_photo = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
                
                for (int i=0; i<self.core_photo.count; i++) {
                    //core_photo에서 managedObject 하나만 뽑아서
                    NSManagedObject *tmp = [self.core_photo objectAtIndex:i];
                    
                    //해당 managedObject의 identifier가 삭제할 사진과 같으면 삭제
                    if ([[tmp valueForKey:@"identifier"] isEqualToString:localIdentifier]) {
                        
                        [context deleteObject:tmp];
                        
                        NSError *error = nil;
                        if(![context save:&error]) {
                            NSLog(@"Delete Failed! %@ %@", error, [error localizedDescription]);
                        }
                    }
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self navigationController] popViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Error: %@", error);
        }
    };
    
    if (self.assetCollection) {
        // Remove asset from album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [changeRequest removeAssets:@[self.receiveImage]];
        } completionHandler:completionHandler];
        
    } else {
        // Delete asset from library
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:@[self.receiveImage]];
        } completionHandler:completionHandler];
        
    }
    
 
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showTag"]) {
        
        TagViewController *tagViewController = segue.destinationViewController;
        tagViewController.asset = self.assetsFetchResults[_section];
        
        tagViewController.img_Category = self.img_Category;
    }
}
@end
