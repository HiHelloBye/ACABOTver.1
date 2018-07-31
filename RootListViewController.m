//
//  RootListViewController.m
//  tf_ios_makefile_example
//
//  Created by SWUCOMPUTER on 2017. 5. 22..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "RootListViewController.h"

#import "AppDelegate.h"
#import "GridViewController.h"
#import "AlbumCell.h"

static CGSize CGSizeScale(CGSize size, CGFloat scale) {
    return CGSizeMake(size.width * scale, size.height * scale);
}


@import Photos;

@interface RootListViewController () <PHPhotoLibraryChangeObserver>

@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;

@property (nonatomic, copy) NSArray *assetCollections;


@end

@implementation RootListViewController

@synthesize category;

static NSString * const AllPhotosReuseIdentifier = @"AllPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

static NSString * const AllPhotosSegue = @"showAllPhotos";
static NSString * const CollectionSegue = @"showCollection";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
    //printf("%d", category.count);
    for(int i=0; i<category.count; i++) {
        
        userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:
                                      [NSString stringWithFormat:@"title == '%@'",
                                      [category objectAtIndex:i]]];
        PHFetchResult *album = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:userAlbumsOptions];
        
        
        if(album.count ==0) {//앨범추가
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:[category objectAtIndex:i]];
            } completionHandler:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"Error creating album: %@", error);
                }
            }];
            
        }
        
    }
    self.title = @"ACABOT";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib
{
    [self.navigationItem setHidesBackButton:YES animated:NO];
    //스마트앨범
    /*PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
     subtype:PHAssetCollectionSubtypeAlbumRegular
     options:nil];*/
    
    //사용자가 등록한 앨범
    //PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
    
    NSMutableArray *selected = [[NSMutableArray alloc] init];
    category = [NSArray arrayWithObjects:@"정리할 사진", @"human", @"animal", @"landscape", @"food", @"concert", @"etc", nil];
    
    for(int i=0; i<category.count; i++) {
        
        userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"title == '%@'", [category objectAtIndex:i]]];
        PHFetchResult *album = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:userAlbumsOptions];
        
        [selected addObject:album];
        
    }
    
    self.collectionsFetchResults = selected;
    //self.collectionsFetchResults = @[topLevelUserCollections];
    self.collectionsLocalizedTitles = @[NSLocalizedString(@"Albums", @"")];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1 + self.collectionsFetchResults.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = 1; // "All Photos" section
    } else {
        PHFetchResult *fetchResult = self.collectionsFetchResults[section - 1];
        numberOfRows = fetchResult.count;
    }
    return numberOfRows;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath {
    CGFloat result;
    if (indexPath.section == 0) {
        result = 180;
    } else {
        result = 180;
    }
    return result;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *localizedTitle = nil;
    AlbumCell *albumCell = nil;
    
    
    if (indexPath.section == 0) {
        albumCell = [tableView dequeueReusableCellWithIdentifier:AllPhotosReuseIdentifier forIndexPath:indexPath];
        
        albumCell.tag = indexPath.row;
        albumCell.borderWidth = 1.0 /[[UIScreen mainScreen] scale];
        
        albumCell.imageView1.image =  [UIImage imageNamed:@"all_photos.png"];
        
    } // end of if
    
    else {
        
        albumCell = [tableView dequeueReusableCellWithIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
        PHFetchResult *fetchResult = self.collectionsFetchResults[indexPath.section - 1];
        PHCollection *collection = fetchResult[indexPath.row];
        localizedTitle = collection.localizedTitle;
        
        albumCell.tag = indexPath.row;
        albumCell.borderWidth = 1.0 /[[UIScreen mainScreen] scale];
        
        if(indexPath.section == 1) //정리할 사진
        {
            albumCell.imageView1.image =   [UIImage imageNamed:@"unclassified.png"];
        }
        if(indexPath.section == 2) //human
        {
             albumCell.imageView1.image =  [UIImage imageNamed:@"human.png"];
        }
        if(indexPath.section == 3) //animal
        {
            albumCell.imageView1.image  =  [UIImage imageNamed:@"animal.png"];
        }
        if(indexPath.section == 4) //landscape
        {
            albumCell.imageView1.image  =  [UIImage imageNamed:@"landscape.png"];
        }
        if(indexPath.section == 5) //food
        {
            albumCell.imageView1.image  =  [UIImage imageNamed:@"food.png"];
        }
        if(indexPath.section == 6) //concert
        {
            albumCell.imageView1.image  =  [UIImage imageNamed:@"concert.png"];
        }
        if(indexPath.section == 7) { //etc폴더
            albumCell.imageView1.image  =  [UIImage imageNamed:@"etc.png"];
        }

    } // end of else

    return albumCell;
    
}
#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
            [self.tableView reloadData];
        }
        
    });
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:AllPhotosSegue]) { //다음 뷰에 모든 사진을 뿌려줌, 사진은 생성일로 정렬됨
        
        GridViewController *assetGridViewController = segue.destinationViewController;
        // Fetch all assets, sorted by date created.
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        assetGridViewController.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
        
        assetGridViewController.all_or_collection = 0; //all photo
        
        assetGridViewController.imgCategory = @"AllPhoto";
        
        //분류하기 버튼 hide
        [assetGridViewController.navigationItem setRightBarButtonItem:nil animated:NO];
        
    } else if ([segue.identifier isEqualToString:CollectionSegue]) {
        
        //다음 뷰에 선택된 셀의 사진을 뿌려줌
        GridViewController *assetGridViewController = segue.destinationViewController;
        
        //분류하기 버튼 hide
        //[assetGridViewController.navigationItem setRightBarButtonItem:nil animated:NO];
        
        //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender]; //선택된 셀의 indexPath 반환
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        if (indexPath.section == 1) {
            
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            assetGridViewController.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
            
            //분류하기 버튼 show
            //[assetGridViewController.navigationItem setRightBarButtonItem:assetGridViewController.cassifyButton animated:NO];
            assetGridViewController.all_or_collection = 1; //정리할 사진
            
            assetGridViewController.imgCategory = @"unclassified";
            
        } else {
            
            PHFetchResult *fetchResult = self.collectionsFetchResults[indexPath.section - 1];
            PHCollection *collection = fetchResult[indexPath.row];
            assetGridViewController.imgCategory = category[indexPath.section-1];
            
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                assetGridViewController.assetsFetchResults = assetsFetchResult;
                assetGridViewController.assetCollection = assetCollection;
            }
            
            //분류하기 버튼 hide
            [assetGridViewController.navigationItem setRightBarButtonItem:nil animated:NO];
            assetGridViewController.all_or_collection = 2; //그 외 카테고리 사진
        }
        
    }
    
}


@end
