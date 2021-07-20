//
//  FriendViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/19/21.
//

#import "FriendViewController.h"
#import <Parse/Parse.h>
#import "SwipeUserCell.h"

@interface FriendViewController () <UITableViewDelegate,UITableViewDataSource,SwipeUserCellDelegate>
@property (strong,nonatomic) NSArray *allUsers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;
@property (nonatomic, strong) UIRefreshControl *refreshControl;


@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self removeCurrentFriends];
    self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(removeCurrentFriends) forControlEvents:UIControlEventValueChanged];
        [self.tableView insertSubview: self.refreshControl atIndex:0];
    // Do any additional setup after loading the view.
}

-(void)setUpFriends:(NSArray *)currFriends{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" notContainedIn:currFriends];
    [query findObjectsInBackgroundWithBlock:^(NSArray <PFUser *> * _Nullable objects, NSError * _Nullable error) {
        if (error==nil){
            self.allUsers = objects;
            for (PFUser *user in self.allUsers){
                NSLog(@"%@",user.username);
            }
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}
-(void)removeCurrentFriends{
    self.cellsCurrentlyEditing = [NSMutableSet new];
    PFQuery *query = [PFQuery queryWithClassName:@"Friend"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object==nil){
            PFObject *friend = [PFObject objectWithClassName:@"Friend"];
            friend[@"userId"] =[PFUser currentUser].objectId;
            friend[@"friendArray"] = [NSMutableArray array];
            [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if (succeeded) {
                  [self setUpFriends:[NSArray arrayWithObject:[PFUser currentUser].objectId]];
                // The object has been saved.
              } else {
                // There was a problem, check error.description
              }
            }];
        }
        else{
            if (object[@"friendArray"]!=nil){
                NSMutableArray *currFriends = object[@"friendArray"];
                [currFriends addObject:[PFUser currentUser].objectId];
                [self setUpFriends:(NSArray *)currFriends];
            }
            else{
                [self setUpFriends:[NSArray arrayWithObject:[PFUser currentUser].objectId]];
            }
            
           
        }
    }];
    
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allUsers.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SwipeUserCell *cell = (SwipeUserCell *) [tableView dequeueReusableCellWithIdentifier:@"SwipeUserCell"];
    cell.user = self.allUsers[indexPath.row];
    cell.delegate = self;
    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
      [cell openCell];
    }
    return cell;
}

- (void)cellDidOpen:(UITableViewCell *)cell {
  NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
  [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell {
  [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}
-(void)addButtonAction:(PFUser *)user{
    NSString *friendId = user.objectId;
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
                NSLog(@"%@",myFriends);
                for (NSString *friendxs in myFriends){
                    NSLog(@"%@",friendxs);
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
-(void)profileButtonAction:(PFUser *)user{
    [self performSegueWithIdentifier:@"viewProfile" sender:user];
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
                NSLog(@"%@",myFriends);
                for (NSString *friendxs in myFriends){
                    NSLog(@"%@",friendxs);
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end
