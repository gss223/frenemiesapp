//
//  Gallery.m
//  frenemies
//
//  Created by Laura Yao on 7/23/21.
//

#import "Gallery.h"
#import <Parse/Parse.h>

@implementation Gallery
@dynamic objectId;
@dynamic logCaption;
@dynamic logImage;
@dynamic challengeId;
@dynamic author;

+ (nonnull NSString *)parseClassName {
    return @"Gallery";
}
+ (void) postGallery: ( UIImage * _Nullable )image withCaption: (NSString *) caption withChallengeId:(NSString *)challengeId withUnit:(NSNumber *)num withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Gallery *newGallery = [Gallery new];
    newGallery.challengeId = challengeId;
    newGallery.logCaption = caption;
    newGallery.logImage = [self getPFFileFromImage:image];
    newGallery.author = [PFUser currentUser];
    [newGallery saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            NSLog(@"succeded in posting gallery");
            PFQuery *query3 = [PFQuery queryWithClassName:@"Log"];
            [query3 whereKey:@"challengeId" equalTo:challengeId];
            [query3 whereKey:@"logger" equalTo:[PFUser currentUser]];
            [query3 getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                NSString *logObjectId = object.objectId;
                PFQuery *query2 = [PFQuery queryWithClassName:@"Log"];
                [query2 getObjectInBackgroundWithId:logObjectId block:^(PFObject * _Nullable logObject, NSError * _Nullable error) {
                    int uam = [logObject[@"unitAmount"] intValue];
                    uam+=[num intValue];
                    logObject[@"unitAmount"] = [NSNumber numberWithInt:uam];
                    [logObject saveInBackground];
                }];
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
