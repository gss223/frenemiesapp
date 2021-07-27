//
//  DoneViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/23/21.
//

#import "DoneViewController.h"

@interface DoneViewController ()

@end

@implementation DoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkIfDataGone];
    // Do any additional setup after loading the view.
}
- (void) getData{
    
}
-(void) checkIfDataGone{
    if (self.challenge.completed){
        [self removeUserData];
        [self removeLink];
    }
    else{
        [self removeLink];
        [self changeChallenge];
        [self removeUserData];
        [self removeStats];
        
    }
}
-(void) removeLink{
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error==nil){
            if(object!=nil){
                NSString *LinkChallengeId = object.objectId;
                PFQuery *query2 = [PFQuery queryWithClassName:@"LinkChallenge"];
                [query2 getObjectInBackgroundWithId:LinkChallengeId block:^(PFObject * _Nullable linkChallenge, NSError * _Nullable error) {
                    NSMutableArray *challArray = linkChallenge[@"challengeArray"];
                    [challArray removeObject:self.challenge.objectId];
                    linkChallenge[@"challengeArray"] = challArray;
                    [linkChallenge saveInBackground];
                }];
            }
        }
    }];
}
-(void) removeUserData{
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject * _Nullable user, NSError * _Nullable error) {
        NSMutableArray *completeChall = user[@"completed"];
        if (completeChall ==nil){
            completeChall = [NSMutableArray array];
        }
        [completeChall addObject:self.challenge.objectId];
        user[@"completed"] = completeChall;
        [user saveInBackground];
    }];
    
}
-(void)removeStats{
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    [query getObjectInBackgroundWithId:@"YydWA5vGjZ" block:^(PFObject * _Nullable stat, NSError * _Nullable error) {
        NSMutableArray *ctArray = stat[@"countArray"];
        for (NSString *tag in self.challenge.tags){
            NSInteger findInd= [stat[@"tagArray"] indexOfObject:tag];
            ctArray[findInd] = [NSNumber numberWithInt:([ctArray[findInd] integerValue] - 1)];
        }
        NSNumber *total = stat[@"total"];
        total = [NSNumber numberWithInt:[total intValue]-1];
        stat[@"countArray"] = ctArray;
        stat[@"total"] = total;
        [stat saveInBackground];
    }];
}
-(void)changeChallenge{
    PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
    [query getObjectInBackgroundWithId:self.challenge.objectId block:^(PFObject * _Nullable chall, NSError * _Nullable error) {
        chall[@"completed"] = @YES;
        [chall saveInBackground];
    }];
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
