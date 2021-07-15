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

+ (nonnull NSString *)parseClassName {
    return @"Challenge";
}

+ (void) postChallenge:(UIImage *)image withOtherinfo:(NSMutableArray *)other withCompletion:(PFBooleanResultBlock)completion{
    
}

@end
