//
//  FriendViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/19/21.
//

#import "FriendViewController.h"
#import <Parse/Parse.h>

@interface FriendViewController () <UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) NSArray *allUsers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Do any additional setup after loading the view.
}

-(void)setUpFriends{
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray <PFUser *> * _Nullable objects, NSError * _Nullable error) {
        self.allUsers = objects;
    }];
    
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allUsers.count;
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
