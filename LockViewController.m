//
//  ViewController.m
//

#import "LockViewController.h"

#import "JKLLockScreenViewController.h"

@interface LockViewController ()<JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate>

//@property (nonatomic, strong) NSString * enteredPincode;

@end

@implementation LockViewController

@synthesize enteredPincode;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *pwd = [NSUserDefaults standardUserDefaults];
    NSString *password = [pwd objectForKey:@"암호"];
    printf("\npwd : %s", [password UTF8String]);
    // self.enteredPincode = @"1111";
    self.enteredPincode = password;
    
    JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
    
    NSUserDefaults *pwdSwitch = [NSUserDefaults standardUserDefaults];
    int pwdSet = [pwdSwitch integerForKey:@"암호설정"];
    if(pwdSet == 1) {
        [viewController setLockScreenMode:0];    // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
        [viewController setDelegate:self];
        [viewController setDataSource:self];
        [viewController setTintColor:[UIColor grayColor]];
        [self presentViewController:viewController animated:YES completion:NULL];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPincodeClikced:(id)sender {
    JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
    [viewController setLockScreenMode:[sender tag]];    // enum { LockScreenModeNormal, LockScreenModeNew, LockScreenModeChange }
    [viewController setDelegate:self];
    [viewController setDataSource:self];
    [viewController setTintColor:[UIColor grayColor]];
    
    [self presentViewController:viewController animated:YES completion:NULL];
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDelegate
- (void)unlockWasCancelledLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    NSLog(@"LockScreenViewController dismiss because of cancel");
}

- (void)unlockWasSuccessfulLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
    self.enteredPincode = pincode;
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDataSource
- (BOOL)lockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
#ifdef DEBUG
    NSLog(@"Entered Pincode : %@", self.enteredPincode);
#endif
    
    return [self.enteredPincode isEqualToString:pincode];
}

- (BOOL)allowTouchIDLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    [self performSegueWithIdentifier:@"unlockSuccess" sender:nil];
    return YES;
}

@end
