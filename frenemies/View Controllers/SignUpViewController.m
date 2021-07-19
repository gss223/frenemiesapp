//
//  SignUpViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/13/21.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.username.text;
    //newUser.email = self.emailField.text;
    newUser.password = self.password.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            myDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FeedTabController"];
            //[self performSegueWithIdentifier:@"successSignUpSegue" sender:nil];
        }
    }];
}
- (IBAction)signupAction:(id)sender {
    [self registerUser];
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
