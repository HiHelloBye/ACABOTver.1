//
//  GridViewCell.h
//  tf_ios_makefile_example
//
//  Created by SWUCOMPUTER on 2017. 5. 22..
//  Copyright © 2017년 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, assign) BOOL showsOverlayViewWhenSelected;

@end
