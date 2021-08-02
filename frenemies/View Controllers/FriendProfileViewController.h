//
//  FriendProfileViewController.h
//  frenemies
//
//  Created by Laura Yao on 7/20/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendProfileViewController : UIViewController
@property (nonatomic,strong) PFUser *user;

@end

NS_ASSUME_NONNULL_END
