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
    self.containerView.backgroundColor = [self generateRandomPastelColor];
    self.containerView.layer.cornerRadius = 20;
    self.containerView.layer.shadowOpacity = 1;
    self.containerView.layer.shadowRadius = 2;
    self.containerView.layer.shadowOffset = CGSizeMake(3,3);
    self.challengeName.text = challenge.challengeName;
    PFFile *cImage= challenge.challengePic;
    //UIImage *backdrop = nil;
    self.challengeImage.layer.cornerRadius = 35;
    self.challengeImage.layer.masksToBounds = YES;
    [cImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.challengeImage.image = [UIImage imageWithData:imageData];
        }
    }];
   
    
    
    
}
-(UIColor*) generateRandomPastelColor
{
    // Randomly generate numbers
    CGFloat red  = ( (CGFloat)(arc4random() % 256) ) / 256;
    CGFloat green  = ( (CGFloat)(arc4random() % 256) ) / 256;
    CGFloat blue  = ( (CGFloat)(arc4random() % 256) ) / 256;

    // Mix with light-blue
    CGFloat mixRed = 1+0xad/256, mixGreen = 1+0xd8/256, mixBlue = 1+0xe6/256;
    red = (red + mixRed) / 3;
    green = (green + mixGreen) / 3;
    blue = (blue + mixBlue) / 3;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

@end
