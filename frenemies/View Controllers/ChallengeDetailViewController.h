//
//  ChallengeDetailViewController.h
//  frenemies
//
//  Created by Laura Yao on 7/21/21.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChallengeDetailViewController : UIViewController
@property (strong, nonatomic) Challenge *challenge;
@property (nonatomic,assign) BOOL added;

@end

NS_ASSUME_NONNULL_END
