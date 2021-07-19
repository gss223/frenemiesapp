//
//  SwipeUserCell.m
//  frenemies
//
//  Created by Laura Yao on 7/19/21.
//

#import "SwipeUserCell.h"

@implementation SwipeUserCell

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
    self.nameField.text = user[@"name"];
    self.profilePic.layer.cornerRadius = 35;
    self.profilePic.layer.masksToBounds = YES;
    PFFile *userImageFile = user[@"imageFile"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.profilePic.image = [UIImage imageWithData:imageData];
        }
    }];
}
- (IBAction)pressedFriend:(id)sender {
}
- (IBAction)clickedProfile:(id)sender {
}



@end
