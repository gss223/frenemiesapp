//
//  Log.m
//  frenemies
//
//  Created by Laura Yao on 7/26/21.
//

#import "Log.h"
#import <Parse/Parse.h>

@implementation Log
@dynamic objectId;
@dynamic challengeId;
@dynamic logger;
@dynamic unitAmount;
+ (nonnull NSString *)parseClassName {
    return @"Log";
}
+ (void)postLog:(NSString *)challengeId withAmount:(NSNumber *)amount withCompletion:(PFBooleanResultBlock _Nullable)completion{
    Log *newLog = [Log new];
    newLog.challengeId = challengeId;
    newLog.logger = [PFUser currentUser];
    newLog.unitAmount = amount;
    [newLog saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            NSLog(@"success log");
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}
+ (void)updateLog:(NSString *)challengeId withAmount:(NSNumber *)amount{
    PFQuery *query = [PFQuery queryWithClassName:@"Log"];
    [query whereKey:@"challengeId" equalTo:challengeId];
    [query whereKey:@"logger" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Log *> * _Nullable objects, NSError * _Nullable error) {
        if (objects ==nil || objects.count==0){
            [self postLog:challengeId withAmount:amount withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (error==nil){
                    NSLog(@"succeded posting");
                }
                else{
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        }
        else{
            NSString *logId = objects[0].objectId;
            PFQuery *query2 = [PFQuery queryWithClassName:@"Log"];
            [query2 getObjectInBackgroundWithId:logId block:^(PFObject * _Nullable logObject, NSError * _Nullable error) {
                if (error ==nil){
                    [logObject incrementKey:@"unitAmount" byAmount:amount];
                }
                else{
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        }
    }];
    
}
@end
