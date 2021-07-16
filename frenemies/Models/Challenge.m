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
    /*if(friends==nil){
        friends = [NSMutableArray array];
    }
    else{
        [friends addObject:[PFUser currentUser].objectId];
    }*/
    [newChallenge saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSString *challengeOId = newChallenge.objectId;
            NSString *yourId =[PFUser currentUser].objectId;
            PFQuery *query = [PFUser query];

                // Retrieve the object by id
                [query getObjectInBackgroundWithId:yourId
                                             block:^(PFObject *user, NSError *error) {
                    if(error==nil){
                        if (user[@"challenges"] ==nil){
                            user[@"challenges"] = [NSMutableArray arrayWithObject:challengeOId];
                        }
                        else{
                            NSMutableArray *challArray =user[@"challenges"];
                            [challArray addObject:challengeOId];
                            user[@"challenges"] = challArray;
                        }
                        NSLog(@"%@",user[@"challenges"]);
                        NSLog(@"success");
                        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (error==nil){
                                NSLog(@"saved user");
                            }
                            else{
                                NSLog(@"%@", error.localizedDescription);
                            }
                        }];
                    }
                    else{
                        NSLog(@"%@", error.localizedDescription);
                    }
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

@end
