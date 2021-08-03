//
//  Gallery.h
//  frenemies
//
//  Created by Laura Yao on 7/23/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Gallery : PFObject <PFSubclassing>

@property (strong,nonatomic) PFUser *author;
@property (strong,nonatomic) NSString *logCaption;
@property (strong,nonatomic) NSString *challengeId;
@property (strong,nonatomic) NSString *objectId;
@property (strong,nonatomic) NSDate *createdAt;
@property (strong,nonatomic) PFFile *logImage;
+ (void) postGallery: ( UIImage * _Nullable )image withCaption: (NSString *) caption withChallengeId:(NSString *)challengeId withUnit:(NSNumber *)num withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
