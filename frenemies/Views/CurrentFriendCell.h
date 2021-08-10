//
//  CurrentFriendCell.h
//  frenemies
//
//  Created by Laura Yao on 8/10/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CurrentFriendCellDelegate
- (void)delButtonAction:(PFUser *)user;
@end

@interface CurrentFriendCell : UITableViewCell
@property (strong,nonatomic) PFUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) id <CurrentFriendCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
