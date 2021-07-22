//
//  RelatedChallengeCell.h
//  frenemies
//
//  Created by Laura Yao on 7/22/21.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

NS_ASSUME_NONNULL_BEGIN

@interface RelatedChallengeCell : UICollectionViewCell
@property (strong,nonatomic) Challenge *challenge;
@property (weak, nonatomic) IBOutlet UIImageView *challengeImage;
@property (weak, nonatomic) IBOutlet UILabel *challengeName;

@end

NS_ASSUME_NONNULL_END
