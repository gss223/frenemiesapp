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
    // Do any additional setup after loading the view.
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
    [dateForm setDateFormat:@"EEE, dd MMM yyy HH:mm"];
    self.timeStart.text = [dateForm stringFromDate:self.challenge.timeStart];
    self.timeEnd.text = [dateForm stringFromDate:self.challenge.timeEnd];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
