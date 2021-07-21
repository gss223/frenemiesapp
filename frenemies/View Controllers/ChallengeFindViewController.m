//
//  ChallengeFindViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/21/21.
//

#import "ChallengeFindViewController.h"
#import "ChallengeFindCell.h"
#import "Challenge.h"
#import <Parse/Parse.h>

@interface ChallengeFindViewController () <UITableViewDelegate,UITableViewDataSource,ChallengeFindCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *allChallenges;
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;

@end

@implementation ChallengeFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setUpChallenges:[NSArray array]];
    // Do any additional setup after loading the view.
}
-(void)setUpChallenges:(NSArray *)avoidChallenges{
    /*PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
    [query whereKey:@"objectId" notContainedIn:avoidChallenges];
    PFQuery *query2 = [PFQuery queryWithClassName:@"Challenge"];
    [query2 whereKey:@"publicorprivate" equalTo:@(true)];
    PFQuery *query3 = [PFQuery queryWithClassName:@"Challenge"];
    [query3 whereKey:@"completed" equalTo:@(false)];*/
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"publicorprivate = true AND NOT(objectId IN %@) AND completed = false",avoidChallenges];
    PFQuery *query = [PFQuery queryWithClassName:@"Challenge" predicate:predicate];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Challenge *> * _Nullable objects, NSError * _Nullable error) {
        self.allChallenges = objects;
        [self.tableView reloadData];
    }];
}
-(void)removeCurrentChallenges{
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allChallenges.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChallengeFindCell *cell = (ChallengeFindCell *) [self.tableView dequeueReusableCellWithIdentifier:@"ChallengeFindCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.challenge = self.allChallenges[indexPath.row];
    return cell;
}
- (void)cellDidOpen:(UITableViewCell *)cell {
  NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
  [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell {
  [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}
-(void)addChallengeButtonAction:(Challenge *)challenge{
    
}
-(void)detailButtonAction:(Challenge *)challenge{
    
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
