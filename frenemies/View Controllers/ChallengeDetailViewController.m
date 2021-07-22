//
//  ChallengeDetailViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/21/21.
//

#import "ChallengeDetailViewController.h"
#import <math.h>
#import <DateTools/DateTools.h>
#import "TagCell.h"
#import "FriendCell.h"
#import <Parse/Parse.h>
#import "RelatedChallengeCell.h"

@interface ChallengeDetailViewController () <UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *challengePic;
@property (weak, nonatomic) IBOutlet UILabel *challengeNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addChallengeButton;
@property (weak, nonatomic) IBOutlet UILabel *timeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeEndLabel;
@property (weak, nonatomic) IBOutlet UITextView *challengeDescripLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *tagView;
@property (weak, nonatomic) IBOutlet UICollectionView *relatedChallengeView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong,nonatomic) NSArray *participants;
@property (strong,nonatomic) NSArray *taggingArray;
@property (strong, nonatomic)NSArray *relatedChallenges;

@end

@implementation ChallengeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tagView.delegate = self;
    self.tagView.dataSource = self;
    [self setUpDetails];
    // Do any additional setup after loading the view.
}
-(void)setUpDetails{
    self.challengeNameLabel.text = self.challenge.challengeName;
    self.challengePic.layer.cornerRadius = 40;
    self.challengePic.layer.masksToBounds = YES;
    PFFile *ImageFile =self.challenge.challengePic;
    [ImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.challengePic.image = [UIImage imageWithData:imageData];
        }
    }];
    DTTimePeriod *lengthOfChallenge = [[DTTimePeriod alloc] initWithStartDate:self.challenge.timeStart endDate:self.challenge.timeEnd];
    double durat = [lengthOfChallenge durationInDays];
    NSString *endDurat =@" day(s)";
    if (durat == 0){
        durat = [lengthOfChallenge durationInMinutes];
        endDurat = @" minute(s)";
    }
    NSString *duration = [[NSNumber numberWithDouble:durat]stringValue];
    self.durationLabel.text = [duration stringByAppendingString:endDurat];
    NSDateFormatter *dateForm = [[NSDateFormatter alloc]init];
    [dateForm setDateFormat:@"EEE, dd MMM yyy HH:mm"];
    self.timeStartLabel.text = [dateForm stringFromDate:self.challenge.timeStart];
    self.timeEndLabel.text = [dateForm stringFromDate:self.challenge.timeEnd];
    [self setUpParticipants];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.tagView.collectionViewLayout;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    CGFloat itemWidth = (self.tagView.frame.size.width-layout.minimumInteritemSpacing*(4-1))/4;
    CGFloat itemHeight = itemWidth*0.3;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.taggingArray = self.challenge.tags;
    /*for (NSString *tag in self.taggingArray){
        NSLog(@"%@",tag);
    }*/
    [self.tagView reloadData];
}
-(void)setUpParticipants{
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
    [query whereKey:@"challengeArray" equalTo:self.challenge.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error==nil){
            NSMutableArray *userIds = [NSMutableArray array];
            for (PFObject *object in objects){
                [userIds addObject:object[@"userId"]];
            }
            PFQuery *query2 = [PFUser query];
            [query2 whereKey:@"objectId" containedIn:(NSArray *)userIds];
            [query2 findObjectsInBackgroundWithBlock:^(NSArray <PFUser *> * _Nullable objects, NSError * _Nullable error) {
                self.participants = objects;
                [self.tableView reloadData];
            }];
        }
    }];
}
-(NSNumber *)calculateRelated:(NSArray *)tagArray withCounts:(NSArray *)countArray withTags:(NSArray *)yourTags withTotal:(NSNumber *)total{
    float counter = [[NSNumber numberWithInt:yourTags.count] floatValue];
    float n = [[NSNumber numberWithInt:yourTags.count] floatValue];
    float totalRelTagVal = 0;
    for (NSString *tag in yourTags){
        NSInteger findInd= [tagArray indexOfObject:tag];
        NSNumber *countofTag = countArray[findInd];
        float tdf = counter/(n*(n+1)/2);
        float df = [countofTag floatValue];
        float totalN = [total floatValue];
        float idf = logf(totalN/(df+1));
        float relTagVal = tdf*idf;
        totalRelTagVal+=relTagVal;
        counter-=1;
    }
    return [NSNumber numberWithFloat:totalRelTagVal];
}
- (IBAction)addChallengeAction:(id)sender {
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.participants.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendCell *cell = (FriendCell *) [self.tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    cell.user = self.participants[indexPath.row];
    return cell;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.tagView){
        return self.taggingArray.count;
    }
    else{
        return self.relatedChallenges.count;
    }
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (collectionView == self.tagView){
        TagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagCell" forIndexPath:indexPath];
        //NSArray *taggingArray =[NSArray arrayWithObjects:@"health", @"fitness",@"food",@"academic",@"social",@"fashion",@"other",nil];
        cell.tagName.text = self.taggingArray[indexPath.row];
        NSLog(self.taggingArray[indexPath.row]);
        cell.contentView.layer.cornerRadius = 5.0;
        cell.contentView.layer.masksToBounds = true;
        cell.contentView.layer.borderColor = [UIColor blackColor].CGColor;
        cell.contentView.layer.borderWidth = 1;
        return cell;
    }
    else{
        RelatedChallengeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RelatedChallengeCell" forIndexPath:indexPath];
        return cell;
    }
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
