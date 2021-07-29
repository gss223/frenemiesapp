//
//  FeedViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/13/21.
//

#import "FeedViewController.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import <Parse/Parse.h>
#import "Challenge.h"
#import "FeedCell.h"
#import "ChallengeViewController.h"
#import "DoneViewController.h"
#import "ChallengeDetailViewController.h"

@interface FeedViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *challengeArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setUpChallenge];
    self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(setUpChallenge) forControlEvents:UIControlEventValueChanged];
        [self.tableView insertSubview: self.refreshControl atIndex:0];
}
-(void) setUpChallenge{
    NSString *yourId =[PFUser currentUser].objectId;
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
    [query whereKey:@"userId" equalTo:yourId];

        // Retrieve the object by id
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if(error==nil){
                NSLog(@"%@",object[@"challengeArray"]);
                NSLog(@"success");
                PFQuery *query2 = [PFQuery queryWithClassName:@"Challenge"];
                [query2 whereKey:@"objectId" containedIn:object[@"challengeArray"]];
                [query2 orderByDescending:@"timeEnd"];
                
                [query2 findObjectsInBackgroundWithBlock:^(NSArray <Challenge *> *objects, NSError *error) {
                  if (!error) {
                      NSLog(@"got challenge");
                      self.challengeArray = objects;
                      [self.tableView reloadData];
                      [self.refreshControl endRefreshing];
                    
                  } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                  }
                }];                
            }
            else{
                NSLog(@"%@", error.localizedDescription);
            }
        }];
}
- (IBAction)logoutAction:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if (error != nil){
                NSLog(@"Error");
            }
            else{
                SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                myDelegate.window.rootViewController = loginViewController;
            }
        }];
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.challengeArray.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedCell* cell = (FeedCell *) [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    cell.challenge = self.challengeArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedCell *cell = (FeedCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.challengeName.text isEqualToString:@"Done"]){
        [self performSegueWithIdentifier:@"doneSegue" sender:cell.challenge];
    }
    else if ([[NSDate date] compare:cell.challenge.timeStart] == NSOrderedAscending){
        [self performSegueWithIdentifier:@"notStartedSegue" sender:cell.challenge];
    }
    else{
        [self performSegueWithIdentifier:@"challengeLogSegue" sender:cell.challenge];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"challengeLogSegue"]){
        Challenge *sentChallenge = sender;
        ChallengeViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.challenge = sentChallenge;
    }
    else if([[segue identifier] isEqualToString:@"doneSegue"]){
        Challenge *sentChallenge = sender;
        DoneViewController *doneViewController = [segue destinationViewController];
        doneViewController.challenge = sentChallenge;
        
    }
    else if ([[segue identifier] isEqualToString:@"notStartedSegue"]){
        Challenge *sentChallenge = sender;
        ChallengeDetailViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.challenge = sentChallenge;
    }
}


@end
