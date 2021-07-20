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


@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.cellsCurrentlyEditing = [NSMutableSet new];
    [self setUpFriends];
    // Do any additional setup after loading the view.
}

-(void)setUpFriends{
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray <PFUser *> * _Nullable objects, NSError * _Nullable error) {
        if (error==nil){
            self.allUsers = objects;
            for (PFUser *user in self.allUsers){
                NSLog(@"%@",user.username);
            }
            [self.tableView reloadData];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allUsers.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SwipeUserCell *cell = (SwipeUserCell *) [tableView dequeueReusableCellWithIdentifier:@"SwipeUserCell"];
    cell.user = self.allUsers[indexPath.row];
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
    
}
-(void)profileButtonAction:(PFUser *)user{
    [self performSegueWithIdentifier:@"viewProfile" sender:user];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
