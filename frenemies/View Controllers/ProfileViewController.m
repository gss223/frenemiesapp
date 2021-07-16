//
//  ProfileViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/14/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settheProfile];
    
}

- (void) settheProfile{
    self.profilePic.layer.cornerRadius = 60;
    self.profilePic.layer.masksToBounds = YES;
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    PFUser *user = [query findObjects][0];
    self.nameField.text = user[@"name"];
    self.username.text = user.username;
    PFFile *userImageFile = user[@"imageFile"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.profilePic.image = [UIImage imageWithData:imageData];
        }
    }];
    
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
