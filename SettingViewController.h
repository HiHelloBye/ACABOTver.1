//
//  testViewController.h
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 6. 10..
//  Copyright © 2017년 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (weak, nonatomic) IBOutlet UISwitch *passwdSwitch;
- (IBAction)setPassword:(id)sender;

- (IBAction)changePressed:(UIButton *)sender;

@end
