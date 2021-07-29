//
//  APIManager.m
//  frenemies
//
//  Created by Laura Yao on 7/28/21.
//

#import "APIManager.h"

@implementation APIManager
+(void)facebookLogin:(void (^)(PFUser * _Nonnull, NSError * _Nonnull))completion{
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email",@"user_friends"] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if(error==nil){
            NSLog(@"success");
            [self putInFacebookData];
            completion(user,error);
        }
        else{
            completion(nil,error);
        }
    }];
}
+(void)linkFacebook:(void (^)(BOOL, NSError * _Nonnull))completion{
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
      [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:@[@"public_profile", @"email",@"user_friends"] block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Woohoo, user is linked with Facebook!");
            completion(succeeded,error);
        }
        else{
            completion(FALSE,error);
        }
      }];
    }
    else{
        [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
          if (succeeded) {
              NSLog(@"The user is no longer associated with their Facebook account.");
              completion(succeeded,error);
          }
          else{
              completion(FALSE,error);
          }
        }];
    }
}
+(void)getFacebookFriends:(void (^)(NSMutableArray * _Nonnull, NSError * _Nonnull))completion{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
        initWithGraphPath:@"/me/friends"
        parameters:@{ @"fields": @"data",}
               HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSArray *friends = result[@"data"];
        NSMutableArray *fbfriends = [NSMutableArray array];
        for (NSDictionary *friend in friends){
            NSLog(@"%@",friend[@"id"]);
            [fbfriends addObject:friend[@"id"]];
        }
        completion(fbfriends,error);
    }];
}
+(void)putInFacebookData{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                   initWithGraphPath:@"/me/"
                                  parameters:@{ @"fields": @"id,name",}
                                          HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        NSString *fbId = result[@"id"];
        NSString *name = result[@"name"];
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject * _Nullable user, NSError * _Nullable error) {
            user[@"name"] = name;
            user[@"fbId"] = fbId;
            [user saveInBackground];
        }];
    }];
}

@end
