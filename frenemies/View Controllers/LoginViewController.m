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
@import Parse;
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end
@implementation LoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
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
