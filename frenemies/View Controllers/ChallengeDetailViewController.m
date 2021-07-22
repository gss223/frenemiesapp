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
@property (strong,nonatomic)NSNumber *totalChallenges;
@property (strong,nonatomic)NSArray *tagArray;
@property (strong,nonatomic)NSArray *countArray;

@end

@implementation ChallengeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tagView.delegate = self;
    self.tagView.dataSource = self;
    self.relatedChallengeView.dataSource = self;
    self.relatedChallengeView.delegate = self;
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
    self.challengeDescripLabel.text = self.challenge.challengeDescription;
    [self setUpParticipants];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.tagView.collectionViewLayout;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    CGFloat itemWidth = (self.tagView.frame.size.width-layout.minimumInteritemSpacing*(4-1))/4;
    CGFloat itemHeight = itemWidth*0.3;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.taggingArray = self.challenge.tags;
    [self.tagView reloadData];
    [self getInitialStats];
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
NSComparisonResult customCompareFunction(NSArray* first, NSArray* second, void* context)
{
    id firstValue = [first objectAtIndex:0];
    id secondValue = [second objectAtIndex:0];
    return [firstValue compare:secondValue];
}
-(NSNumber *)calculateRelated:(NSArray *)yourTags{
    float counter = [[NSNumber numberWithInt:yourTags.count] floatValue];
    float n = [[NSNumber numberWithInt:yourTags.count] floatValue];
    float totalRelTagVal = 0;
    for (NSString *tag in yourTags){
        NSInteger findInd= [self.tagArray indexOfObject:tag];
        NSNumber *countofTag = self.countArray[findInd];
        float tdf = counter/(n*(n+1)/2);
        float df = [countofTag floatValue];
        float totalN = [self.totalChallenges floatValue];
        float idf = logf(totalN/(df+1));
        float relTagVal = tdf*idf;
        totalRelTagVal+=relTagVal;
        counter-=1;
    }
    return [NSNumber numberWithFloat:totalRelTagVal];
}
-(void)getInitialStats{
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error==nil){
            self.totalChallenges = object[@"total"];
            self.tagArray = object[@"tagArray"];
            self.countArray = object[@"countArray"];
            [self setUpRelated];
        }
    }];
}
-(void)setUpRelated{
    NSNumber *compareWeight = [self calculateRelated:self.challenge.tags];
    NSMutableArray *queries = [NSMutableArray array];
    for (NSString *tag in self.challenge.tags){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN tags AND objectId!=%@ AND completed = false AND publicorprivate = true",tag,self.challenge.objectId];
        PFQuery *query = [PFQuery queryWithClassName:@"Challenge" predicate:predicate];
        //[query whereKey:@"tags" equalTo:tag];
        [queries addObject:query];
    }
    PFQuery *combinedquery = [PFQuery orQueryWithSubqueries:queries];
    [combinedquery findObjectsInBackgroundWithBlock:^(NSArray <Challenge *> * _Nullable objects, NSError * _Nullable error) {
        NSMutableArray *yourTags = [NSMutableArray array];
        NSMutableArray *weightTags = [NSMutableArray array];
        for (Challenge *chall in objects){
            [yourTags addObject:chall.tags];
        }
        int count = 0;
        for (NSArray *yourTag in yourTags){
            [weightTags addObject:[NSArray arrayWithObjects:[self calculateAbsRelated:yourTag withBaseVal:compareWeight],[NSNumber numberWithInt:count], nil]];
            count+=1;
        }
        NSArray* sortedTagArray = [weightTags sortedArrayUsingFunction:customCompareFunction context:NULL];
        NSMutableArray *topTen = [NSMutableArray array];
        NSInteger amountRel = 10;
        if (sortedTagArray.count<10){
            amountRel = weightTags.count;
        }
        for (int i = 0; i<amountRel; i++){
            NSInteger j = [sortedTagArray[i][1] intValue];
            [topTen addObject:objects[j]];
        }
        self.relatedChallenges = (NSArray *)topTen;
        [self.relatedChallengeView reloadData];
    }];
}
-(NSNumber *)calculateAbsRelated:(NSArray *)yourTags withBaseVal:(NSNumber *)value{
    float tagWeight = [[self calculateRelated:yourTags] floatValue];
    float difBetween = tagWeight - [value floatValue];
    return [NSNumber numberWithFloat:fabsf(difBetween)];
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
        //NSLog(self.taggingArray[indexPath.row]);
        cell.contentView.layer.cornerRadius = 5.0;
        cell.contentView.layer.masksToBounds = true;
        cell.contentView.layer.borderColor = [UIColor blackColor].CGColor;
        cell.contentView.layer.borderWidth = 1;
        return cell;
    }
    else{
        RelatedChallengeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RelatedChallengeCell" forIndexPath:indexPath];
        cell.challenge = self.relatedChallenges[indexPath.row];
        NSLog (@"%@",cell.challenge.challengeName);
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
