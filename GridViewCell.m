//
//  GridViewCell.m
//  tf_ios_makefile_example
//
//  Created by SWUCOMPUTER on 2017. 5. 22..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "GridViewCell.h"

@interface GridViewCell ()

@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (strong) IBOutlet UIImageView *imageView;

@end

@implementation GridViewCell

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.overlayView.hidden = !(selected && self.showsOverlayViewWhenSelected);
}
@end
