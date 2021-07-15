//
//  FriendCell.h
//  frenemies
//
//  Created by Laura Yao on 7/14/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendCell : UITableViewCell

@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *friendPic;

@end

NS_ASSUME_NONNULL_END
