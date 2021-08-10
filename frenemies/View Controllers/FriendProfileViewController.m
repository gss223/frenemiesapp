//
//  FriendProfileViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/20/21.
//

#import "FriendProfileViewController.h"

@interface FriendProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *friendProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UILabel *friendUsername;
@property (weak, nonatomic) IBOutlet UIButton *addFriend;

@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
}
-(void)setUpView{
    self.friendName.text = self.user[@"name"];
    self.friendUsername.text = self.user.username;
    if(self.added){
        [self.addFriend setTitle:@"Added" forState:UIControlStateNormal];
        self.addFriend.enabled = NO;
    }
    else{
        [self.addFriend setTitle:@"Add Friend" forState:UIControlStateNormal];
        self.addFriend.enabled = YES;
    }
    self.friendProfilePic.layer.cornerRadius = 145/2;
    self.friendProfilePic.layer.masksToBounds = YES;
    PFFile *ImageFile =self.user[@"profilePic"];
    [ImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.friendProfilePic.image = [UIImage imageWithData:imageData];
        }
    }];
}
- (IBAction)addButtonAction:(id)sender {
    [self.addFriend setTitle:@"Added" forState:UIControlStateNormal];
    self.addFriend.enabled = NO;
    [self addingFriend];
}
#pragma mark - Save Friends
-(void)addingFriend{
    NSString *friendId = self.user.objectId;
    NSLog (@"%@",friendId);
    
    NSString *yourId = [PFUser currentUser].objectId;
    NSLog(@"%@",yourId);
    PFQuery *query = [PFQuery queryWithClassName:@"Friend"];
    [query whereKey:@"userId" equalTo:yourId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object==nil){
            PFObject *friend = [PFObject objectWithClassName:@"Friend"];
            friend[@"userId"] =[PFUser currentUser].objectId;
            friend[@"friendArray"] = [NSMutableArray arrayWithObject:friendId];
            [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if (succeeded) {
                  [self saveFriend:yourId withyourId:friendId];
              } else {
                // There was a problem, check error.description
              }
            }];
        }
        else{
            
            NSString *fOid = object.objectId;
            NSLog(@"%@",fOid);
            PFQuery *query2 = [PFQuery queryWithClassName:@"Friend"];

            // Retrieve the object by id
            [query2 getObjectInBackgroundWithId:fOid
                                         block:^(PFObject *friend, NSError *error) {
                NSMutableArray *myFriends = friend[@"friendArray"];
                if (myFriends ==nil){
                    myFriends = [NSMutableArray arrayWithObject:friendId];
                }
                else{
                    [myFriends addObject:friendId];
                }
                friend[@"friendArray"] = [NSMutableArray arrayWithArray:myFriends];
                NSLog(@"addedFriend");
                
                [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded){
                        NSLog(@"success");
                        [self saveFriend:yourId withyourId:friendId];
                    }
                    else{
                        NSLog(@"failed");
                    }
                }];
            }];
            
           
        }
    }];
}
-(void)saveFriend:(NSString *)friendId withyourId:(NSString *)yourId{
    PFQuery *query = [PFQuery queryWithClassName:@"Friend"];
    [query whereKey:@"userId" equalTo:yourId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object==nil){
            PFObject *friend = [PFObject objectWithClassName:@"Friend"];
            friend[@"userId"] =[PFUser currentUser].objectId;
            friend[@"friendArray"] = [NSMutableArray arrayWithObject:friendId];
            [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if (succeeded) {
                // The object has been saved.
              } else {
                // There was a problem, check error.description
              }
            }];
        }
        else{
            
            NSString *fOid = object.objectId;
            NSLog(@"%@",fOid);
            PFQuery *query2 = [PFQuery queryWithClassName:@"Friend"];

            // Retrieve the object by id
            [query2 getObjectInBackgroundWithId:fOid
                                         block:^(PFObject *friend, NSError *error) {
                NSMutableArray *myFriends = friend[@"friendArray"];
                if (myFriends ==nil){
                    myFriends = [NSMutableArray arrayWithObject:friendId];
                }
                else{
                    [myFriends addObject:friendId];
                }
                friend[@"friendArray"] = [NSMutableArray arrayWithArray:myFriends];
                NSLog(@"addedFriend");
                
                [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded){
                        NSLog(@"success");
                    }
                    else{
                        NSLog(@"failed");
                    }
                }];
            }];
        }
    }];
}
@end
