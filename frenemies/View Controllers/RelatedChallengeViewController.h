//
//  RelatedChallengeViewController.h
//  frenemies
//
//  Created by Laura Yao on 7/28/21.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

NS_ASSUME_NONNULL_BEGIN

@interface RelatedChallengeViewController : UIViewController
@property (strong,nonatomic) Challenge *challenge;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (strong,nonatomic) NSString *linkChallengeId;

@end

NS_ASSUME_NONNULL_END
