//
//  FirstViewController.m
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 6. 10..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *pwdSwitch = [NSUserDefaults standardUserDefaults];
    int pwdSet = [pwdSwitch integerForKey:@"암호설정"];
    if(pwdSet == 1) {
        [self performSegueWithIdentifier:@"toLockView" sender:nil];

    }
    else {
        [self performSegueWithIdentifier:@"toRootView" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
