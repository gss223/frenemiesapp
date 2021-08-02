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
#import "RelatedChallengeViewController.h"
#import "MZFormSheetPresentationViewControllerSegue.h"
#import "MZFormSheetPresentationViewController.h"


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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *challengeAddButton;
@property (strong,nonatomic) NSArray *participants;
@property (strong,nonatomic) NSArray *taggingArray;
@property (strong, nonatomic)NSArray *relatedChallenges;
@property (strong,nonatomic)NSNumber *totalChallenges;
@property (strong,nonatomic)NSArray *tagArray;
@property (strong,nonatomic)NSArray *countArray;
@property (strong,nonatomic) NSString *linkChallengeId;

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
}
-(void)setUpDetails{
    self.challengeNameLabel.text = self.challenge.challengeName;
    self.challengePic.layer.cornerRadius = 30;
    self.challengePic.layer.masksToBounds = YES;
    self.challengeAddButton.title = @"Add Challenge";
    self.challengeAddButton.enabled = YES;
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
    [dateForm setDateFormat:@"EEE, M/d/yy HH:mm"];
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
-(void)getInitialStats{
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error==nil){
            self.totalChallenges = object[@"total"];
            self.tagArray = object[@"tagArray"];
            self.countArray = object[@"countArray"];
            [self removeCurrent];
        }
    }];
}
-(void)setUpRelated:(NSArray *)currChall{
    NSNumber *compareWeight = [self calculateRelated:self.challenge.tags];
    NSMutableArray *queries = [NSMutableArray array];
    for (NSString *tag in self.challenge.tags){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN tags AND objectId!=%@ AND completed = false AND publicorprivate = true AND NOT(objectId IN %@)",tag,self.challenge.objectId,currChall];
        PFQuery *query = [PFQuery queryWithClassName:@"Challenge" predicate:predicate];
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
        NSLog(@"%@", compareWeight);
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
-(void)removeCurrent{
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object==nil){
            PFObject *challenge = [PFObject objectWithClassName:@"LinkChallenge"];
            challenge[@"userId"] =[PFUser currentUser].objectId;
            challenge[@"challengeArray"] = [NSMutableArray array];
            [challenge saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if (succeeded) {
                  self.linkChallengeId = challenge.objectId;
                  [self setUpRelated:[NSArray array]];
                // The object has been saved.
              } else {
                // There was a problem, check error.description
              }
            }];
        }
        else{
            self.linkChallengeId = object.objectId;
            if (object[@"challengeArray"]!=nil){
                NSMutableArray *currChallenge = object[@"challengeArray"];
                [self setUpRelated:(NSArray *)currChallenge];
            }
            else{
                [self setUpRelated:[NSArray array]];
            }
            
           
        }
    }];
}
- (IBAction)challengeAddAction:(id)sender {
    self.challengeAddButton.title = @"Added";
    self.challengeAddButton.enabled = NO;
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
#pragma mark - UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.participants.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendCell *cell = (FriendCell *) [self.tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    cell.user = self.participants[indexPath.row];
    return cell;
}
#pragma mark - UICollectionView
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
        cell.tagName.text = self.taggingArray[indexPath.row];
        cell.contentView.layer.cornerRadius = 5.0;
        cell.contentView.layer.masksToBounds = true;
        cell.contentView.layer.borderColor = [UIColor blackColor].CGColor;
        cell.contentView.layer.borderWidth = 1;
        return cell;
    }
    else{
        RelatedChallengeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RelatedChallengeCell" forIndexPath:indexPath];
        cell.challenge = self.relatedChallenges[indexPath.row];
        return cell;
    }
}
- (UINavigationController *)formSheetControllerWithNavigationController {
    return [self.storyboard instantiateViewControllerWithIdentifier:@"formSheetController"];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.relatedChallengeView){
       UINavigationController *navigationController = [self formSheetControllerWithNavigationController];
        MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:navigationController];
        formSheetController.presentationController.shouldDismissOnBackgroundViewTap = YES;
        formSheetController.presentationController.shouldApplyBackgroundBlurEffect = YES;
        RelatedChallengeViewController *rcViewController = [navigationController.viewControllers firstObject];
        
        rcViewController.challenge = self.relatedChallenges[indexPath.row];
        rcViewController.linkChallengeId = self.linkChallengeId;
        formSheetController.presentationController.shouldCenterVertically = YES;
        
        formSheetController.presentationController.contentViewSize =  CGSizeMake(300, 450);

        [self presentViewController:formSheetController animated:YES completion:nil];
    }
}
#pragma mark - relatedChallengeAlgo
-(NSNumber *)calculateAbsRelated:(NSArray *)yourTags withBaseVal:(NSNumber *)value{
    float tagWeight = [[self calculateRelated:yourTags] floatValue];
    float difBetween = tagWeight - [value floatValue];
    return [NSNumber numberWithFloat:fabsf(difBetween)];
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

#pragma mark - helpers
NSComparisonResult customCompareFunction(NSArray* first, NSArray* second, void* context)
{
    id firstValue = [first objectAtIndex:0];
    id secondValue = [second objectAtIndex:0];
    return [firstValue compare:secondValue];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
