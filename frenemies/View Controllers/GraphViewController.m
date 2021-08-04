//
//  GraphViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/28/21.
//

#import "GraphViewController.h"

@interface GraphViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation GraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    [navigationBar setTranslucent:YES];
}
-(void) setUpView{
    self.nameLabel.text = self.user[@"name"];
    self.usernameLabel.text = self.user.username;
    self.profilePic.layer.cornerRadius = 35;
    self.profilePic.layer.masksToBounds = YES;
    PFFile *ImageFile =self.user[@"profilePic"];
    [ImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.profilePic.image = [UIImage imageWithData:imageData];
        }
    }];
}

@end
