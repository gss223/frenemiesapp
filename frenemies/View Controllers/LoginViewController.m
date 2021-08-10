//
//  LoginViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/12/21.
//

#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import <PFFacebookUtils.h>
#import "SceneDelegate.h"
#import "APIManager.h"
#import "Colours.h"
@import Parse;
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *facebookCont;

@end
@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.buttonLogin.backgroundColor=[UIColor coralColor];
    self.buttonLogin.clipsToBounds = YES;
    self.buttonLogin.layer.cornerRadius = 3;
    self.facebookCont.backgroundColor=[UIColor tealColor];
    self.facebookCont.clipsToBounds = YES;
    self.facebookCont.layer.cornerRadius = 3;
}
- (IBAction)loginAction:(id)sender {
    [APIManager facebookLogin:^(PFUser * _Nonnull user, NSError * _Nonnull error) {
        if (error==nil){
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            myDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FeedTabController"];
        }
    }];
}
- (void)loginUser {
    NSString *username = self.username.text;
    NSString *password = self.password.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully");
            
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            myDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FeedTabController"];
        }
    }];
}
- (IBAction)normalLogin:(id)sender {
    [self loginUser];
}
- (IBAction)signupAction:(id)sender {
    [self performSegueWithIdentifier:@"signUpSegue" sender:nil];
}

@end
