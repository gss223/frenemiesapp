//
//  RelatedChallengeViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/28/21.
//

#import "RelatedChallengeViewController.h"

@interface RelatedChallengeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *challengeImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *challengeDescription;
@property (weak, nonatomic) IBOutlet UILabel *timeStart;
@property (weak, nonatomic) IBOutlet UILabel *timeEnd;
@property (weak, nonatomic) IBOutlet UIButton *addChallengeButton;

@end

@implementation RelatedChallengeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    [self checkCurrent];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    [navigationBar setTranslucent:YES];
}
-(void)setUpView{
    self.nameLabel.text = self.challenge.challengeName;
    self.challengeDescription.text = self.challenge.challengeDescription;
    PFFile *ImageFile =self.challenge.challengePic;
    [ImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.challengeImage.image = [UIImage imageWithData:imageData];
        }
    }];
    NSDateFormatter *dateForm = [[NSDateFormatter alloc]init];
    [dateForm setDateFormat:@"EEE, M/d/yy HH:mm"];
    self.timeStart.text = [dateForm stringFromDate:self.challenge.timeStart];
    self.timeEnd.text = [dateForm stringFromDate:self.challenge.timeEnd];
}
-(void)checkCurrent{
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
    [query getObjectInBackgroundWithId:self.linkChallengeId
                                 block:^(PFObject *linkChallenge, NSError *error) {
        NSMutableArray *challenges = linkChallenge[@"challengeArray"];
        if ([challenges containsObject:self.challenge.objectId]){
            [self.addChallengeButton setTitle:@"Added" forState:UIControlStateNormal];
            self.addChallengeButton.enabled = NO;
        }
        else{
            [self.addChallengeButton setTitle:@"Add Challenge" forState:UIControlStateNormal];
            self.addChallengeButton.enabled = YES;
        }
      
    }];
}
- (IBAction)addChallengeAction:(id)sender {
    [self.addChallengeButton setTitle:@"Added" forState:UIControlStateNormal];
    self.addChallengeButton.enabled = NO;
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];

    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.linkChallengeId
                                 block:^(PFObject *linkChallenge, NSError *error) {
        NSMutableArray *challenges = linkChallenge[@"challengeArray"];
        [challenges addObject:self.challenge.objectId];
        linkChallenge[@"challengeArray"] = challenges;
        [linkChallenge saveInBackground];
    }];
}

@end
