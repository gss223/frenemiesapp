//
//  ChallengeViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/23/21.
//

#import "ChallengeViewController.h"
#import "UICountingLabel.h"
#import "Log.h"
#import "Gallery.h"
#import "LogViewController.h"
#import <Parse/Parse.h>
#import <DateTools/DateTools.h>
#import "GalleryCell.h"
#import "MZFormSheetPresentationViewControllerSegue.h"
#import "MZFormSheetPresentationViewController.h"
#import "GraphViewController.h"
#import <Charts-Swift.h>
@import Charts;

@interface ChallengeViewController () <ChartViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

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
@property (weak, nonatomic) IBOutlet UILabel *timeLeft;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic) NSArray *gallery;

@end

@implementation ChallengeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.horBarChart.delegate = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self getYourUser];
    [self getLogData];
    [self getGalleryData];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
}
-(void)getYourUser{
    [PFUser getCurrentUserInBackground];
}
-(void)setUpViews{
    if ([self.amount intValue]==1){
        self.unitsUsed.text = self.challenge.unitChosen;
    }
    else{
        self.unitsUsed.text = [self.challenge.unitChosen stringByAppendingString:@"s"];
    }
    
    self.totalPeople.text = [self.totalParticipants stringValue];
    self.place.text = [self.rank stringValue];
    self.countLabel.format = @"%d";
    self.countLabel.method = UILabelCountingMethodLinear;
    [self.countLabel countFromZeroTo:[self.amount floatValue]];
    [self setUpGraph];
    NSTimeInterval ti = [self.challenge.timeEnd timeIntervalSinceDate:[NSDate date]];
    NSUInteger h, m, s;
    h = (ti / 3600);
    m = ((NSUInteger)(ti / 60)) % 60;
    s = ((NSUInteger) ti) % 60;
    NSString *durat = [NSString stringWithFormat:@"%lu:%02lu:%02lu", h, m, s];
    self.timeLeft.text = durat;
}
-(void)onTimer{
    NSTimeInterval ti = [self.challenge.timeEnd timeIntervalSinceDate:[NSDate date]];
    NSUInteger h, m, s;
    h = (ti / 3600);
    m = ((NSUInteger)(ti / 60)) % 60;
    s = ((NSUInteger) ti) % 60;
    NSString *durat = [NSString stringWithFormat:@"%lu:%02lu:%02lu", h, m, s];
    self.timeLeft.text = durat;
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
    BarChartDataSet *chartdataset = [[BarChartDataSet alloc] initWithEntries:barChartDataEntries label:[self.challenge.unitChosen stringByAppendingString:@"s"]];
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
        
    ChartYAxis *rightAxis =self.horBarChart.rightAxis;
    rightAxis.enabled = NO;
        
    ChartLegend *l = self.horBarChart.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;
    l.form = ChartLegendFormSquare;
    l.formSize = 8.0;
    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    l.xEntrySpace = 4.0;
    [self.horBarChart animateWithYAxisDuration:2.5];
}
-(void)getLogData{
    PFQuery *query = [PFQuery queryWithClassName:@"Log"];
    [query whereKey:@"challengeId" equalTo:self.challenge.objectId];
    [query includeKey:@"logger"];
    [query orderByDescending:@"unitAmount"];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Log *> * _Nullable objects, NSError * _Nullable error) {
        if (objects ==nil ||objects.count==0){
            [Log postLog:self.challenge.objectId withAmount:[NSNumber numberWithInt:0] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (error==nil){
                    NSLog(@"succesfully logged");
                }
            }];
            self.logNumbers = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:0]];
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
-(void)getGalleryData{
    PFQuery *query = [PFQuery queryWithClassName:@"Gallery"];
    [query whereKey:@"challengeId" equalTo:self.challenge.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Gallery *> * _Nullable objects, NSError * _Nullable error) {
        if (error==nil){
            self.gallery = objects;
            [self.collectionView reloadData];
        }
    }];
    
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.gallery.count;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GalleryCell *cell = (GalleryCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    cell.gallery = self.gallery[indexPath.row];
    return cell;
}
- (IBAction)logAction:(id)sender {
    [self performSegueWithIdentifier:@"unitLogSegue" sender:self.challenge];
}
- (NSString * _Nonnull)stringForValue:(double)value axis:(ChartAxisBase * _Nullable)axis
{
    return @"";
}
- (UINavigationController *)formSheetControllerWithNavigationController {
    return [self.storyboard instantiateViewControllerWithIdentifier:@"gFormSheetController"];
}
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
    double i = entry.x;
    NSLog (@"%@",self.participants[(int)i][@"username"]);
    UINavigationController *navigationController = [self formSheetControllerWithNavigationController];
     MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:navigationController];
     formSheetController.presentationController.shouldDismissOnBackgroundViewTap = YES;
     formSheetController.presentationController.shouldApplyBackgroundBlurEffect = YES;
     GraphViewController *gViewController = [navigationController.viewControllers firstObject];
     
     gViewController.user = self.participants[(int)i];
     formSheetController.presentationController.shouldCenterVertically = YES;
     
     formSheetController.presentationController.contentViewSize =  CGSizeMake(265, 336);

     [self presentViewController:formSheetController animated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"unitLogSegue"]){
        Challenge *sentChallenge = sender;
        LogViewController *logViewController = [segue destinationViewController];
        logViewController.challenge = sentChallenge;
        logViewController.log = self.yourLog;
    }
}


@end
