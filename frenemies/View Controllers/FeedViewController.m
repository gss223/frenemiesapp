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
#import "Colours.h"

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
    
    UILabel *navTitle = [[UILabel alloc] init];
    navTitle.frame = CGRectMake(0,0,190,45);
    navTitle.text = @"Challenges";
    navTitle.font = [UIFont fontWithName:@"Rockwell-Bold" size:25];
    navTitle.backgroundColor = [UIColor clearColor];
    navTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = navTitle;
    self.navigationItem.title = @"";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundColor:[UIColor tealColor]];
    [navigationBar setTranslucent:YES];
}
-(void) viewWillAppear:(BOOL)animated{
    [self setUpChallenge];
}
-(void) setUpChallenge{
    NSString *yourId =[PFUser currentUser].objectId;
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
    [query whereKey:@"userId" equalTo:yourId];
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

#pragma mark - UITableView
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
        detailsViewController.added = true;
    }
}


@end
