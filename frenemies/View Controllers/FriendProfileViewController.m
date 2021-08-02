//
//  FriendProfileViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/20/21.
//

#import "FriendProfileViewController.h"

@interface FriendProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *friendProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UILabel *friendUsername;
@property (weak, nonatomic) IBOutlet UIButton *addFriend;

@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    // Do any additional setup after loading the view.
}
-(void)setUpView{
    self.friendName.text = self.user[@"name"];
    self.friendUsername.text = self.user.username;
    PFFile *ImageFile =self.user[@"profilePic"];
    [ImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.friendProfilePic.image = [UIImage imageWithData:imageData];
        }
    }];
}

@end
