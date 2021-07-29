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
#import "ChallengeDetailViewController.h"

@interface ChallengeFindViewController () <UITableViewDelegate,UITableViewDataSource,ChallengeFindCellDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *allChallenges;
@property (strong,nonatomic) NSArray *filteredData;
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong) NSString *linkChallengeId;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ChallengeFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    [self removeCurrentChallenges];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(removeCurrentChallenges) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview: self.refreshControl atIndex:0];
}
-(void)setUpChallenges:(NSArray *)avoidChallenges{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"publicorprivate = true AND NOT(objectId IN %@) AND completed = false",avoidChallenges];
    PFQuery *query = [PFQuery queryWithClassName:@"Challenge" predicate:predicate];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Challenge *> * _Nullable objects, NSError * _Nullable error) {
        if (error==nil){
            self.allChallenges = objects;
            self.filteredData = self.allChallenges;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
-(void)removeCurrentChallenges{
    self.cellsCurrentlyEditing = [NSMutableSet new];
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object==nil){
            PFObject *challenge = [PFObject objectWithClassName:@"LinkChallenge"];
            challenge[@"userId"] =[PFUser currentUser].objectId;
            challenge[@"challengeArray"] = [NSMutableArray array];
            [challenge saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if (succeeded) {
                  self.linkChallengeId = challenge.objectId;
                  [self setUpChallenges:[NSArray array]];
                // The object has been saved.
              } else {
                // There was a problem, check error.description
              }
            }];
        }
        else{
            self.linkChallengeId = object.objectId;
            if (object[@"challengeArray"]!=nil){
                NSMutableArray *currChallenge = object[@"challengeArray"];
                [self setUpChallenges:(NSArray *)currChallenge];
            }
            else{
                [self setUpChallenges:[NSArray array]];
            }
            
           
        }
    }];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredData.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChallengeFindCell *cell = (ChallengeFindCell *) [self.tableView dequeueReusableCellWithIdentifier:@"ChallengeFindCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.challenge = self.filteredData[indexPath.row];
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
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];

    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.linkChallengeId
                                 block:^(PFObject *linkChallenge, NSError *error) {
        NSMutableArray *challenges = linkChallenge[@"challengeArray"];
        [challenges addObject:challenge.objectId];
        linkChallenge[@"challengeArray"] = challenges;
        [linkChallenge saveInBackground];
    }];
    
}
-(void)detailButtonAction:(Challenge *)challenge{
    [self performSegueWithIdentifier:@"viewChallengeDetail" sender:challenge];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Challenge *evaluatedObject, NSDictionary *bindings) {
            return ([evaluatedObject.challengeName.lowercaseString containsString:searchText.lowercaseString] || [evaluatedObject.challengeDescription.lowercaseString containsString:searchText.lowercaseString]);
        }];
        self.filteredData = [self.allChallenges filteredArrayUsingPredicate:predicate];
        
        //NSLog(@"%@", self.filteredData);
        
    }
    else {
        self.filteredData = self.allChallenges;
    }
    
    [self.tableView reloadData];
 
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"viewChallengeDetail"]){
        Challenge *sentChallenge = sender;
        ChallengeDetailViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.challenge = sentChallenge;
    }
}


@end
