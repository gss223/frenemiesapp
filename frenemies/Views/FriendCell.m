//
//  FriendCell.m
//  frenemies
//
//  Created by Laura Yao on 7/14/21.
//

#import "FriendCell.h"

@implementation FriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setUser:(PFUser *)user {
    _user = user;
    self.username.text = user.username;
    self.name.text = user[@"name"];
    self.friendPic.layer.cornerRadius = 20;
    self.friendPic.layer.masksToBounds = YES;
    PFFile *userImageFile = user[@"profilePic"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.friendPic.image = [UIImage imageWithData:imageData];
        }
    }];
}

@end
