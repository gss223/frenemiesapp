//
//  Challenge.m
//  frenemies
//
//  Created by Laura Yao on 7/15/21.
//

#import "Challenge.h"
#import <Parse/Parse.h>

@implementation Challenge
@dynamic objectId;
@dynamic challengeName;
@dynamic createdBy;
@dynamic challengeDescription;
@dynamic challengePic;
@dynamic publicorprivate;
@dynamic completed;
@dynamic createdAt;
@dynamic timeStart;
@dynamic timeEnd;
@dynamic tags;
@dynamic unitChosen;

+ (nonnull NSString *)parseClassName {
    return @"Challenge";
}

+ (void) postChallenge:(UIImage *)image withOtherinfo:(NSArray *)other withCompletion:(PFBooleanResultBlock)completion{
    Challenge *newChallenge = [Challenge new];
    newChallenge.challengePic = [self getPFFileFromImage:image];
    newChallenge.challengeName = other[0];
    newChallenge.challengeDescription = other[1];
    newChallenge.publicorprivate = [other[2] boolValue];
    newChallenge.timeStart = other[3];
    newChallenge.timeEnd = other[4];
    newChallenge.tags = other[6];
    newChallenge.completed = false;
    newChallenge.createdAt = [NSDate date];
    newChallenge.createdBy = [PFUser currentUser];
    newChallenge.unitChosen = other[5];
    NSMutableArray *friends = other[7];
    if(friends==nil){
        friends = [NSMutableArray array];
    }
    [newChallenge saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSString *challengeOId = newChallenge.objectId;
            NSString *yourId =[PFUser currentUser].objectId;
            PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
            [query whereKey:@"userId" equalTo:yourId];

                // Retrieve the object by id
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if(objects==nil || objects.count==0){
                    PFObject *newLink = [PFObject objectWithClassName:@"LinkChallenge"];
                    newLink[@"userId"] = yourId;
                    newLink[@"challengeArray"] = [NSMutableArray arrayWithObject:challengeOId];
                    [newLink saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                      if (succeeded) {
                          [self saveForFriends:friends withChallengeId:challengeOId];
                      }
                      else {
                        // There was a problem, check error.description
                      }
                    }];
                }
                else{
                
                    if(error==nil){
                        PFObject *user = objects[0];
                        if (user[@"challengeArray"] ==nil){
                            user[@"challengeArray"] = [NSMutableArray arrayWithObject:challengeOId];
                        }
                        else{
                            NSMutableArray *challArray =user[@"challengeArray"];
                            [challArray addObject:challengeOId];
                            user[@"challengeArray"] = challArray;
                        }
                        NSLog(@"%@",user[@"challengeArray"]);
                        NSLog(@"success");
                        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (error==nil){
                                NSLog(@"saved user");
                                [self saveForFriends:friends withChallengeId:challengeOId];
                            }
                            else{
                                NSLog(@"%@", error.localizedDescription);
                            }
                        }];
                    }
                    else{
                        NSLog(@"%@", error.localizedDescription);
                    }}
                }];
        }
    }];
}
+ (PFFile *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFile fileWithName:@"image.png" data:imageData];
}

+ (void)saveForFriends: (NSMutableArray *)friends withChallengeId:(NSString *)challengeId{
    for (NSString *friend in friends){
        PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
        [query whereKey:@"userId" equalTo:friend];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects==nil || objects.count==0){
                PFObject *newLink = [PFObject objectWithClassName:@"LinkChallenge"];
                newLink[@"userId"] = friend;
                newLink[@"challengeArray"] = [NSMutableArray arrayWithObject:challengeId];
                [newLink saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                  if (succeeded) {
                    // The object has been saved.
                  } else {
                    // There was a problem, check error.description
                  }
                }];
            }
            else{
                PFQuery *query2 = [PFQuery queryWithClassName:@"LinkChallenge"];

                // Retrieve the object by id
                [query2 getObjectInBackgroundWithId:objects[0][@"objectId"]
                                             block:^(PFObject *linkChall, NSError *error) {
                    // Now let's update it with some new data. In this case, only cheatMode and score
                    // will get sent to the cloud. playerName hasn't changed.
                    if (linkChall[@"challengeArray"] ==nil){
                        linkChall[@"challengeArray"] = [NSMutableArray arrayWithObject:challengeId];
                    }
                    else{
                        NSMutableArray *challArray =linkChall[@"challengeArray"];
                        [challArray addObject:challengeId];
                        linkChall[@"challengeArray"] = challArray;
                    }
                    [linkChall saveInBackground];
                }];
            }
        }];
    }
}

@end
