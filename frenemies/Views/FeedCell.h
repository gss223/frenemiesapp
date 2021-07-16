//
//  FeedCell.h
//  frenemies
//
//  Created by Laura Yao on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

NS_ASSUME_NONNULL_BEGIN

@interface FeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *challengeName;
//@property (weak, nonatomic) IBOutlet UIImageView *challengeImage;
@property (nonatomic, strong) Challenge *challenge;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

NS_ASSUME_NONNULL_END
