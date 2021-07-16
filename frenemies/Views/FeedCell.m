//
//  FeedCell.m
//  frenemies
//
//  Created by Laura Yao on 7/14/21.
//

#import "FeedCell.h"

@implementation FeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setChallenge:(Challenge *)challenge{
    _challenge = challenge;
    self.containerView.layer.cornerRadius = 20;
    self.containerView.layer.shadowOpacity = 1;
    self.containerView.layer.shadowRadius = 2;
    self.containerView.layer.shadowOffset = CGSizeMake(3,3);
    self.challengeName.text = challenge.challengeName;
    PFFile *cImage= challenge.challengePic;
    //UIImage *backdrop = nil;
    [cImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithData:imageData]];
        }
    }];
    /*UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial]];
    blur.frame = self.containerView.bounds;
    [self.containerView insertSubview:blur atIndex:0];*/
    
    
    
}

@end
