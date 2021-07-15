//
//  Challenge.h
//  frenemies
//
//  Created by Laura Yao on 7/15/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Challenge : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *challengeName;
@property (nonatomic, strong) PFUser *createdBy;
@property (nonatomic, strong) NSString *challengeDescription;
@property (nonatomic, strong) PFFile *challengePic;
@property (nonatomic, assign) BOOL publicorprivate;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *timeStart;
@property (nonatomic, strong) NSDate *timeEnd;
@property (nonatomic, strong) NSMutableArray *tags;

+ (void) postChallenge: ( UIImage * _Nullable )image withOtherinfo: (NSMutableArray *) other withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
