//
//  LoginViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/12/21.
//

#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import<Parse/Parse.h>
#import <PFFacebookUtils.h>
@import Parse;
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end
// Add this to the body
@implementation LoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  /*FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
  // Optional: Place the button in the center of your view.
  loginButton.center = self.view.center;
  loginButton.readPermissions = @[@"public_profile", @"email",@"user_friends"];
  [self.view addSubview:loginButton];
  if ([FBSDKAccessToken currentAccessToken]) {
       [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
        startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
          if (!error) {
             NSLog(@"fetched user:%@", result);
          }
      }];
    }*/
}
- (IBAction)loginAction:(id)sender {
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email",@"user_friends"] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if(error==nil){
            NSLog(@"success");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
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
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}
- (IBAction)normalLogin:(id)sender {
    [self loginUser];
}
- (IBAction)signupAction:(id)sender {
    [self performSegueWithIdentifier:@"signUpSegue" sender:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
