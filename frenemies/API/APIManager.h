//
//  APIManager.h
//  frenemies
//
//  Created by Laura Yao on 7/28/21.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import <PFFacebookUtils.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+(void)facebookLogin:(void(^)(PFUser *user, NSError *error))completion;
+(void)getFacebookFriends:(void(^)(NSMutableArray *friends, NSError *error))completion;
+(void)linkFacebook:(void(^)(BOOL succeeded, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
