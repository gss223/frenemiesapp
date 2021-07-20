//
//  SwipeUserCell.h
//  frenemies
//
//  Created by Laura Yao on 7/19/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SwipeUserCellDelegate <NSObject>
- (void)addButtonAction:(PFUser *)user;
- (void)profileButtonAction:(PFUser *)user;
- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;
@end
@interface SwipeUserCell : UITableViewCell
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, weak) id <SwipeUserCellDelegate> delegate;
- (void)openCell;

@end
NS_ASSUME_NONNULL_END
