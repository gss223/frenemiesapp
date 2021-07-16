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

@interface FeedViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *challengeArray;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setUpChallenge];
    // Do any additional setup after loading the view.
}
-(void) setUpChallenge{
    NSString *yourId =[PFUser currentUser].objectId;
    PFQuery *query = [PFUser query];

        // Retrieve the object by id
        [query getObjectInBackgroundWithId:yourId
                                     block:^(PFObject *user, NSError *error) {
            if(error==nil){
                //NSArray *challengeIds = [NSArray arrayWithArray:user[@"challenges"]];
                NSLog(@"%@",user[@"challenges"]);
                NSLog(@"success");
                PFQuery *query2 = [PFQuery queryWithClassName:@"Challenge"];
                [query2 whereKey:@"objectId" containedIn:user[@"challenges"]];
                
                [query2 findObjectsInBackgroundWithBlock:^(NSArray <Challenge *> *objects, NSError *error) {
                  if (!error) {
                      NSLog(@"got challenge");
                      self.challengeArray = objects;
                      for (Challenge *chall in self.challengeArray){
                          NSLog(chall.challengeName);
                      }
                      [self.tableView reloadData];
                    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
