//
//  FeedCell.m
//  frenemies
//
//  Created by Laura Yao on 7/14/21.
//

#import "FeedCell.h"
#import "Colours.h"

@implementation FeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(void)setChallenge:(Challenge *)challenge{
    _challenge = challenge;
    self.containerView.layer.cornerRadius = 20;
    self.containerView.layer.shadowOpacity = 1;
    self.containerView.layer.shadowRadius = 2;
    self.containerView.layer.shadowOffset = CGSizeMake(3,3);
    if ([[NSDate date] compare:challenge.timeEnd] == NSOrderedDescending){
        self.challengeImage.image = [UIImage imageNamed:@"celebrate"];
        self.challengeName.text = @"Done";
        self.containerView.backgroundColor = [self generateCellColor:@"" withDone:true];
    }
    else{
        self.containerView.backgroundColor = [self generateCellColor:challenge.tags[0] withDone:false];
        self.challengeName.text = challenge.challengeName;
        PFFile *cImage= challenge.challengePic;
        self.challengeImage.layer.cornerRadius = 35;
        self.challengeImage.layer.masksToBounds = YES;
        [cImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                self.challengeImage.image = [UIImage imageWithData:imageData];
            }
        }];
    }
}
-(UIColor *)generateCellColor:(NSString *)firstTag withDone:(BOOL)done{
    if (done){
        return [UIColor paleGreenColor];
    }
    else{
        if([firstTag isEqualToString:@"health"]){
            return [UIColor robinEggColor];
        }
        else if ([firstTag isEqualToString:@"fitness"]){
            return [UIColor easterPinkColor];
        }
        else if ([firstTag isEqualToString:@"food"]){
            return [UIColor pastelOrangeColor];
        }
        else if ([firstTag isEqualToString:@"academic"]){
            return [UIColor palePurpleColor];
        }
        else if ([firstTag isEqualToString:@"social"]){
            return [UIColor babyBlueColor];
        }
        else if ([firstTag isEqualToString:@"fashion"]){
            return [UIColor paleRoseColor];
        }
        else{
            return [UIColor peachColor];
        }
    }
}

@end
