//
//  testViewController.m
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 6. 10..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "SettingViewController.h"
#import "JKLLockScreenViewController.h"
#import "LockViewController.h"

@interface SettingViewController () <JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate>

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *pwdSwitch = [NSUserDefaults standardUserDefaults];
    int pwdSet = [pwdSwitch integerForKey:@"암호설정"];
    if(pwdSet == 1) {
        [self.passwdSwitch setOn:YES animated:YES];
    }
    
    
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setPassword:(id)sender {
    NSUserDefaults *pwdSwitch = [NSUserDefaults standardUserDefaults]; //초기화

    if([self.passwdSwitch isOn]) {
        [pwdSwitch setInteger:1 forKey:@"암호설정"]; //암호설정 on
        [pwdSwitch synchronize];
        
        JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
        [viewController setLockScreenMode:1];
        [viewController setDelegate:self];
        [viewController setDataSource:self];
        [viewController setTintColor:[UIColor grayColor]];

        [self presentViewController:viewController animated:YES completion:NULL];
        [self.changeButton setEnabled:YES];

    }
    else {
        [pwdSwitch setInteger:0 forKey:@"암호설정"]; //암호설정 off
        [pwdSwitch synchronize];
        [self.changeButton setEnabled:NO];
        [self.changeButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

    }
    
}

- (IBAction)changePressed:(UIButton *)sender {
    if([self.changeButton isEnabled]) {
        JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
        [viewController setLockScreenMode:2];
        [viewController setDelegate:self];
        [viewController setDataSource:self];
        [viewController setTintColor:[UIColor grayColor]];
        
        [self presentViewController:viewController animated:YES completion:NULL];
    }
}

@end
