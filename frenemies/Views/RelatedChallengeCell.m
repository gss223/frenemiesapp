//
//  RelatedChallengeCell.m
//  frenemies
//
//  Created by Laura Yao on 7/22/21.
//

#import "RelatedChallengeCell.h"

@implementation RelatedChallengeCell

-(void)setChallenge:(Challenge *)challenge{
    _challenge = challenge;
    self.challengeName.text = challenge.challengeName;
    self.challengeImage.layer.cornerRadius = 20;
    self.challengeImage.layer.masksToBounds = YES;
    PFFile *imageFile = challenge.challengePic;
    [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.challengeImage.image = [UIImage imageWithData:imageData];
        }
    }];
}

@end
