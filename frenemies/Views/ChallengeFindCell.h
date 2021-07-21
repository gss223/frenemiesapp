//
//  ChallengeFindCell.h
//  frenemies
//
//  Created by Laura Yao on 7/21/21.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ChallengeFindCellDelegate <NSObject>
- (void)addChallengeButtonAction:(Challenge *)challenge;
- (void)detailButtonAction:(Challenge *)challenge;
- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;
@end
@interface ChallengeFindCell : UITableViewCell
@property (nonatomic, strong) Challenge *challenge;
@property (nonatomic, weak) id <ChallengeFindCellDelegate> delegate;
- (void)openCell;

@end

NS_ASSUME_NONNULL_END
