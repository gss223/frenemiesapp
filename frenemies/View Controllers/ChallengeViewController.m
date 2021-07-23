//
//  ChallengeViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/23/21.
//

#import "ChallengeViewController.h"
#import "UICountingLabel.h"
#import <Charts-Swift.h>
@import Charts;

@interface ChallengeViewController ()

@property (weak, nonatomic) IBOutlet HorizontalBarChartView *horBarChart;
@property (weak, nonatomic) IBOutlet UICountingLabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitsUsed;
@property (weak, nonatomic) IBOutlet UILabel *place;
@property (weak, nonatomic) IBOutlet UILabel *totalPeople;

@end

@implementation ChallengeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)logAction:(id)sender {
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
