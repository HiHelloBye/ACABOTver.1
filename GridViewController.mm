//
//  GridViewController.m
//  tf_ios_makefile_example
//
//  Created by SWUCOMPUTER on 2017. 5. 22..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "GridViewController.h"
#import "GridViewCell.h"
#import "AssetViewController.h"
#import "RootListViewController.h"
#import "LGAlertView.h"
#include "RunModelViewController.h"
#import <CoreData/CoreData.h>

@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end


@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end

@interface GridViewController () <PHPhotoLibraryChangeObserver> {
    CGFloat _margin, _gutter;
}
@property (strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;

@end


@implementation GridViewController

//@synthesize all_photo;
@synthesize not_classified_photo;
@synthesize all_or_collection;
@synthesize core_photo, identifiers;
@synthesize imgCategory;

static NSString * const CellReuseIdentifier = @"AssetCell";
static CGSize AssetGridThumbnailSize;

//CoreData context return
- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)awakeFromNib
{
    _gutter = 1;
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
    
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    //CoreData Fetch -> core_photo 배열에 NSMangedObject 형으로 들어옴
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
    core_photo = [[moc executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    //NSManagedObject 에서 identifier String 만 identifiers배열에 넣음
    for (int i=0; i<core_photo.count; i++) {
        NSManagedObject *tmp = [core_photo objectAtIndex:i];
        [identifiers addObject:[tmp valueForKey:@"identifier"]];
    }
    
    //coreData identifier에 없으면(분류되지 않은 경우) not_classified_photo에 해당 asset 추가
    for (int i=0; i<self.assetsFetchResults.count; i++) {
        
        PHAsset *asset = self.assetsFetchResults[i];
        if (![identifiers containsObject:asset.localIdentifier]) {
            
            [not_classified_photo addObject:asset];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCachedAssets];

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Save indexPath for the last item
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    
    // Update layout
    [self.collectionViewLayout invalidateLayout];
    
    // Restore scroll position
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [imgCategory uppercaseString];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    //all_photo = [[NSMutableArray alloc] init];
    not_classified_photo = [[NSMutableArray alloc] init];
    identifiers = [[NSMutableArray alloc] init];

}
/*
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
 }*/

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    AssetViewController *assetViewController = segue.destinationViewController;
    assetViewController.section = indexPath.row;
    assetViewController.img_Category = imgCategory;

    
    if( all_or_collection == 0 || all_or_collection == 2) { //all photo or category photo
        assetViewController.assetsFetchResults = self.assetsFetchResults;

    }
    else {
        assetViewController.assetsFetchResults = (PHFetchResult *)not_classified_photo; //정리할사진

    }
    
    assetViewController.asset = self.assetsFetchResults[indexPath.item];
    assetViewController.assetCollection = self.assetCollection;
    assetViewController.all_or_collection = self.all_or_collection;

}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
        if (collectionChanges) {
            
            // get the new fetch result
            self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
            
            UICollectionView *collectionView = self.collectionView;
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // we need to reload all if the incremental diffs are not available
                [collectionView reloadData];
                
            } else {
                // if we have incremental diffs, tell the collection view to animate insertions and deletions
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}

#pragma mark <UICollectionViewDataSource>

/*- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
 #warning Incomplete implementation, return the number of sections
 return 0;
 }*/


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (all_or_collection == 1) {
        return not_classified_photo.count;
    } else {
        NSInteger count = self.assetsFetchResults.count;
        return count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    //PHFetchResult *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[@"B84E8479-475C-4727-A4A4-B77AA9980897/L0/001"] options:nil];
    
    if (all_or_collection == 0) { //all photo
        
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        //[all_photo addObject:asset];
        //NSLog(@"all photo : %d\n", all_photo.count);
        cell.showsOverlayViewWhenSelected = asset;
        [self.imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                      // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                      if (cell.tag == currentTag) {
                                          cell.thumbnailImage = result;
                                      }
                                      
                                  }];
        
        return cell;
        
        
    } else if (all_or_collection == 1) { //정리할 사진
        
        //assetsFetchResults가 아닌 not_classified_photo에서 asset을 가져옴
        PHAsset *new_asset = self.not_classified_photo[indexPath.item];
        
        [self.imageManager requestImageForAsset:new_asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                      // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                      if (cell.tag == currentTag) {
                                          cell.thumbnailImage = result;
                                      }
                                      
                                  }];
        
        return cell;
        
        
    } else { //카테고리별 사진
        
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [self.imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                      // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                      if (cell.tag == currentTag) {
                                          cell.thumbnailImage = result;
                                      }
                                      
                                  }];
        
        return cell;
        
    }

}
//셀 간격 조절
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat value = (self.view.bounds.size.width - 5 * _gutter - 2 * _margin) / 4;
    return CGSizeMake(value, value);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _gutter;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *) collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _gutter;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

//classify 버튼
- (IBAction)classifyButtonPressed:(UIBarButtonItem *)sender {
    
   
    if (not_classified_photo.count == 0) {
      
        //분류할 사진이 없을때 예외처리
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"WARNING" message:@"분류할 사진이 없습니다" style:LGAlertViewStyleAlert buttonTitles:nil cancelButtonTitle:@"OK" destructiveButtonTitle:nil];
        
        [alertView showAnimated:YES completionHandler:nil];
        
    }
    else {
        
        LGAlertView *alertView = [[LGAlertView alloc] initWithActivityIndicatorAndTitle:@"Classifying"
                                                                                message:@"Waiting please"
                                                                                  style:LGAlertViewStyleAlert
                                                                      progressLabelText:@"분류중입니다..."
                                                                           buttonTitles:nil
                                                                      cancelButtonTitle:nil
                                                                 destructiveButtonTitle:nil
                                                                               delegate:nil]; //self
        
        [alertView showAnimated:YES completionHandler:nil];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
            if (alertView && alertView.isShowing) {
                __block UIImage *result_image;
                int nHuman = 0; int nAnimal = 0; int nLandscape = 0; int nFood = 0; int nConcert= 0; int nEtc = 0;

                for (int i=0; i<not_classified_photo.count; i++) {
                //for(int i=0; i<1; i++){
            
    
                    CGFloat scale = [UIScreen mainScreen].scale;
                    CGSize targetSize = CGSizeMake(600 * scale, 400 * scale);
                    
                    //정리할 사진 배열에 있던 사진을 하나씩 가져와서 이미지로 변환
                    PHAsset *asset = [not_classified_photo objectAtIndex:i];

                    [self.imageManager requestImageForAsset:asset
                                                 targetSize:targetSize
                                                contentMode:PHImageContentModeAspectFit
                                                    options:nil
                                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                                  
                                                  //NSLog(@"%d 실행", i);
                                                  result_image = result;
                                                  
                    }];
                                                      
                    //NSLog(@"%d 번째", i);

                    // Convert UIImage to JPEG and save at document folder
                    NSData *imgData = UIImageJPEGRepresentation(result_image, 0.7);
                                                      
                    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
                    [imgData writeToFile:jpgPath atomically:YES];
                    NSLog(@"으어어어어어");
                    
                    //전역변수로
                    AppDelegate *mAPP = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    mAPP.dimagePath = jpgPath;
                    
                    NSString *tensor = Classify_Image();
                                                       
                    //printf("\n\n\n[[[[%s \n", [tensor UTF8String]);
                    NSLog(@"으어어어어어1111");
                    
                    //해당 카테고리에 사진 추가
                    PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
                    userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"title == '%@'", tensor]];
                    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:userAlbumsOptions];
                    NSLog(@"으어어어어어2222");
                    
                    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
                        //NSLog(@"album title %@", collection.localizedTitle);
                                                          
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                                              
                            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                                                              [assetCollectionChangeRequest addAssets:@[asset]];
                                                              
                                                              
                        } completionHandler:^(BOOL success, NSError *error) {
                                                              
                            if (!success) {
                                NSLog(@"Error add asset: %@", error);
                            }else{
                                NSLog(@"%@ - Created", tensor);
                            }
                                                              
                        }];
                                                          
                    }];

                    NSString *localIdentifier = asset.localIdentifier;
                    NSLog(@"%d 번째 identifier >> %@\n", i, localIdentifier);
                    
                    //identifier을 coreData에 저장
                    
                    NSManagedObjectContext *context = nil;
                    id delegate = [[UIApplication sharedApplication] delegate];
                    
                    if ([delegate performSelector:@selector(managedObjectContext)]) {
                        context = [delegate managedObjectContext];
                    }
                    
                    NSManagedObject *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                                              inManagedObjectContext:context];
                    
                    [newPhoto setValue:asset.localIdentifier forKey:@"identifier"];
                    
                    NSError *error = nil;
                    if (![context save:&error]) {
                        NSLog(@"Save Failed! %@ %@", error, [error userInfo]);
                    } else {
                        NSLog(@"Save Success!");
                    }
                    
                    if([tensor isEqualToString:@"human"]) nHuman ++;
                    if([tensor isEqualToString:@"animal"]) nAnimal ++;
                    if([tensor isEqualToString:@"landscape"]) nLandscape ++;
                    if([tensor isEqualToString:@"food"]) nFood ++;
                    if([tensor isEqualToString:@"concert"]) nConcert ++;
                    if([tensor isEqualToString:@"etc"]) nEtc ++;
                    
                }
                
                NSString *finish = [NSString stringWithFormat:@"HUMAN %d장\nANIMAL %d장\nLANDSCAPE %d장\nFOOD %d장\nCONCERT %d장\nETC %d장",
                                    nHuman, nAnimal, nLandscape, nFood, nConcert, nEtc];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
                    if (alertView && alertView.isShowing) {
                        [alertView dismissAnimated:YES completionHandler:nil];
                        [self.navigationController popViewControllerAnimated:YES];
                        
                        LGAlertView *finishView = [[LGAlertView alloc] initWithTitle:@"분류가 완료되었습니다!" message:finish style:LGAlertViewStyleAlert buttonTitles:nil cancelButtonTitle:@"OK" destructiveButtonTitle:nil];
                        [finishView showAnimated:YES completionHandler:nil];
                    }
                });
            }
        });
        //[self.navigationController popViewControllerAnimated:YES];
        
    }

}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
     GridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 1)
        return;
    NSArray<NSIndexPath*>* selectedIndexes = collectionView.indexPathsForSelectedItems;
    for (int i = 0; i < selectedIndexes.count; i++) {
        NSIndexPath* currentIndex = selectedIndexes[i];
        if (![currentIndex isEqual:indexPath] && currentIndex.section != 1) {
            [collectionView deselectItemAtIndexPath:currentIndex animated:YES];
        }
    }
    
    [cell setSelected:YES];
}
- (IBAction)selectionButtonPressed:(id)sender {
    [self.collectionView  setAllowsMultipleSelection:YES];
}

#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */


@end
