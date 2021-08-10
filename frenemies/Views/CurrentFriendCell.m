//
//  CurrentFriendCell.m
//  frenemies
//
//  Created by Laura Yao on 8/10/21.
//

#import "CurrentFriendCell.h"

@implementation CurrentFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setUser:(PFUser *)user{
    _user = user;
    self.nameLabel.text = user[@"name"];
    self.usernameLabel.text = user.username;
    self.profilePic.layer.cornerRadius = 30;
    self.profilePic.layer.masksToBounds = YES;
    PFFile *userImageFile = user[@"profilePic"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.profilePic.image = [UIImage imageWithData:imageData];
        }
    }];
}
- (IBAction)deleteFriend:(id)sender {
    [self.delegate delButtonAction:self.user];
}

@end
