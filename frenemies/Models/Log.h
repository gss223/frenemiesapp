//
//  Log.h
//  frenemies
//
//  Created by Laura Yao on 7/26/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Log : PFObject <PFSubclassing>
@property (strong,nonatomic) NSString *objectId;
@property(strong,nonatomic) NSString *challengeId;
@property (strong,nonatomic) PFUser *logger;
@property (strong,nonatomic) NSNumber *unitAmount;
+(void)updateLog:(NSString *)challengeId withAmount:(NSNumber *)amount;
+(void)postLog:(NSString *)challengeId withAmount:(NSNumber *)amount withCompletion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
