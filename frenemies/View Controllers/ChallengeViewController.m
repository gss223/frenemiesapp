//
//  ChallengeViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/23/21.
//

#import "ChallengeViewController.h"
#import "UICountingLabel.h"
#import "Log.h"
#import <Parse/Parse.h>
#import <Charts-Swift.h>
@import Charts;

@interface ChallengeViewController () <ChartViewDelegate>

@property (weak, nonatomic) IBOutlet HorizontalBarChartView *horBarChart;
@property (weak, nonatomic) IBOutlet UICountingLabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitsUsed;
@property (weak, nonatomic) IBOutlet UILabel *place;
@property (weak, nonatomic) IBOutlet UILabel *totalPeople;
@property (strong,nonatomic) NSArray *logs;
@property (strong,nonatomic) NSMutableArray *logNumbers;
@property (strong,nonatomic) NSMutableArray *participants;
@property (strong,nonatomic) NSNumber *amount;
@property (strong,nonatomic) NSNumber *totalParticipants;
@property (strong,nonatomic) NSNumber *rank;
@property (strong,nonatomic) Log *yourLog;
@property (strong,nonatomic) NSMutableArray *usernames;
@property (strong,nonatomic) PFUser *user;

@end

@implementation ChallengeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.horBarChart.delegate = self;
    [self getYourUser];
    [self getLogData];
    // Do any additional setup after loading the view.
}
-(void)getYourUser{
    [PFUser getCurrentUserInBackground];
}
-(void)setUpViews{
    self.unitsUsed.text = self.challenge.unitChosen;
    self.totalPeople.text = [self.totalParticipants stringValue];
    self.place.text = [self.rank stringValue];
    self.countLabel.format = @"%d";
    self.countLabel.method = UILabelCountingMethodLinear;
    [self.countLabel countFromZeroTo:[self.amount floatValue]];
    [self setUpGraph];
}
-(void)setUpGraph{
    [self graphComp];
    NSMutableArray <BarChartDataEntry *> *barChartDataEntries = [NSMutableArray array];
    self.usernames = [NSMutableArray array];
    int count = 5;
    if ([self.totalParticipants intValue]<5){
        count = [self.totalParticipants intValue];
    }
    for (int i = 0; i<count; i++){
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:(double)i y:[self.logNumbers[i] doubleValue]];
        [barChartDataEntries addObject:entry];
        [self.usernames addObject:self.participants[i][@"username"]];
    }
    BarChartDataSet *chartdataset = [[BarChartDataSet alloc] initWithEntries:barChartDataEntries label:self.challenge.unitChosen];
    BarChartData *data = [[BarChartData alloc] initWithDataSet:chartdataset];
    
    self.horBarChart.data = data;
    self.horBarChart.xAxis.valueFormatter = self;
}
-(void)graphComp{
    ChartXAxis *xAxis = self.horBarChart.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.labelFont = [UIFont systemFontOfSize:5.f];
        xAxis.drawAxisLineEnabled = YES;
        xAxis.drawGridLinesEnabled = NO;
        xAxis.granularity = 10.0;
        
    ChartYAxis *leftAxis = self.horBarChart.leftAxis;
        leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
        leftAxis.drawAxisLineEnabled = YES;
        leftAxis.drawGridLinesEnabled = NO;
        //leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        
    ChartYAxis *rightAxis =self.horBarChart.rightAxis;
        rightAxis.enabled = NO;
        rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
        rightAxis.drawAxisLineEnabled = YES;
        rightAxis.drawGridLinesEnabled = NO;
        rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        
    ChartLegend *l = self.horBarChart.legend;
        l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
        l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
        l.orientation = ChartLegendOrientationHorizontal;
        l.drawInside = NO;
        l.form = ChartLegendFormSquare;
        l.formSize = 8.0;
        l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
        l.xEntrySpace = 4.0;
}
-(void)getLogData{
    PFQuery *query = [PFQuery queryWithClassName:@"Log"];
    [query whereKey:@"challengeId" equalTo:self.challenge.objectId];
    //[query whereKey:@"logger" equalTo:[PFUser currentUser]];
    [query includeKey:@"logger"];
    [query orderByDescending:@"unitAmount"];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Log *> * _Nullable objects, NSError * _Nullable error) {
        if (objects ==nil ||objects.count==0){
            [Log postLog:self.challenge.objectId withAmount:[NSNumber numberWithInt:0] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (error==nil){
                    NSLog(@"succesfully logged");
                }
            }];
            self.logNumbers = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:1]];
            self.participants = [NSMutableArray arrayWithObject:[PFUser currentUser]];
            self.totalParticipants = [NSNumber numberWithInt:1];
            self.amount =[NSNumber numberWithInt:0];
            self.rank =[NSNumber numberWithInt:1];
        }
        else{
            self.logs = objects;
            self.logNumbers = [NSMutableArray array];
            self.participants = [NSMutableArray array];
            self.totalParticipants = [NSNumber numberWithInt:objects.count];
            BOOL yourLogexists = false;
            int counter = 0;
            for (Log *log in self.logs){
                if ([log.logger.objectId isEqualToString:[PFUser currentUser].objectId] ){
                    yourLogexists = true;
                    self.amount = log.unitAmount;
                    self.yourLog = log;
                    self.rank = [NSNumber numberWithInt:(counter+1)];
                }
                [self.logNumbers addObject:log.unitAmount];
                [self.participants addObject:log.logger];
                counter +=1;
            }
            if (yourLogexists ==false){
                self.amount = [NSNumber numberWithInt:0];
                [Log postLog:self.challenge.objectId withAmount:[NSNumber numberWithInt:0] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded){
                        
                    }
                }];
                [self.logNumbers addObject:self.amount];
                [self.participants addObject:[PFUser currentUser]];
                self.totalParticipants = [NSNumber numberWithInt:[self.totalParticipants intValue]+1];
                self.rank = self.totalParticipants;
            }
        }
        
        [self setUpViews];
        
    }];
    
}
- (IBAction)logAction:(id)sender {
}
- (NSString * _Nonnull)stringForValue:(double)value axis:(ChartAxisBase * _Nullable)axis
{
    NSString *xAxisStringValue = @"";
    int myInt = (int)value;

    if(self.usernames.count > myInt)
        xAxisStringValue = [self.usernames objectAtIndex:myInt];

    return @"";
}
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
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
