//
//  ProfileViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/14/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import <PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SwipeUserCell.h"
#import "APIManager.h"
#import "Colours.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,SwipeUserCellDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UIButton *facebookLink;
@property (strong, nonatomic) UIImage *setPic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *fbfriends;
@property (strong,nonatomic) NSArray *fbfriendUser;
@property (strong,nonatomic) NSMutableArray *currentFriends;
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self settheProfile];
    [self fixFacebookButton];
    
    UITapGestureRecognizer *photoTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPhoto:)];
    [self.profilePic addGestureRecognizer:photoTapGestureRecognizer];
    [self.profilePic setUserInteractionEnabled:YES];
    
    self.navigationItem.title = @"";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    [navigationBar setTranslucent:YES];
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Rockwell-Bold" size:25], NSForegroundColorAttributeName : [UIColor blackColor]};
    
}
-(void) fixFacebookButton{
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        [self.facebookLink setTitle:@"Link to Facebook" forState:UIControlStateNormal];
    }
    else{
        [self.facebookLink setTitle:@"Unlink from Facebook" forState:UIControlStateNormal];
    }
}
- (void) settheProfile{
    self.profilePic.layer.cornerRadius = 60;
    self.profilePic.layer.masksToBounds = YES;
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray <PFUser *> * _Nullable objects, NSError * _Nullable error) {
        PFUser *user = objects[0];
        self.nameField.text = user[@"name"];
        self.username.text = user.username;
        PFFile *userImageFile = user[@"profilePic"];
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                self.profilePic.image = [UIImage imageWithData:imageData];
            }
        }];
        [self currentFriendData];
    }];
}

#pragma mark - Button Actions
- (IBAction)saveChanges:(id)sender {
    PFQuery *query = [PFUser query];

        // Retrieve the object by id
    [query getObjectInBackgroundWithId:[PFUser currentUser].objectId
                                     block:^(PFObject *user, NSError *error) {
        if(error==nil){
            user[@"profilePic"] = [self getPFFileFromImage:[self resizeI:self.setPic withSize:self.setPic.size]];
            user[@"name"] = self.nameField.text;
            NSLog(@"success");
            [user saveInBackground];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
        
}
- (IBAction)facebookLink:(id)sender {
    [APIManager linkFacebook:^(BOOL succeeded, NSError * _Nonnull error) {
        if (succeeded){
            NSLog(@"Woohoo, user is linked with Facebook!");
        }
    }];
}

#pragma mark - Getting Data
-(void)currentFriendData{
    PFQuery *query = [PFQuery queryWithClassName:@"Friend"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object == nil){
            PFObject *friend = [PFObject objectWithClassName:@"Friend"];
            friend[@"userId"] =[PFUser currentUser].objectId;
            friend[@"friendArray"] = [NSMutableArray array];
            [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if (succeeded) {
                  self.currentFriends = [NSMutableArray array];
              } else {
                // There was a problem, check error.description
              }
            }];
        }
        else{
            self.currentFriends = object[@"friendArray"];
        }
        [self getFacebookUserId];
    }];
}
-(void)getFacebookUserId{
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [APIManager getFacebookFriends:^(NSMutableArray * _Nonnull friends, NSError * _Nonnull error) {
            self.fbfriends = friends;
            [self getFbFriendsData];
        }];
    }
    
}
-(void) getFbFriendsData{
    PFQuery *query = [PFUser query];
    [query whereKey:@"fbId" containedIn:self.fbfriends];
    [query findObjectsInBackgroundWithBlock:^(NSArray <PFUser *> * _Nullable objects, NSError * _Nullable error) {
        self.fbfriendUser = objects;
        [self.tableView reloadData];
    }];
}
#pragma mark - SwipeUserCellDelegate
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
    [self performSegueWithIdentifier:@"friendProfileSegue" sender:user];
}
#pragma mark - Saving Friends
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
#pragma mark - UITableView
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fbfriendUser.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SwipeUserCell *cell = (SwipeUserCell *) [tableView dequeueReusableCellWithIdentifier:@"SwipeUserCell"];
    cell.user = self.fbfriendUser[indexPath.row];
    cell.delegate = self;
    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
      [cell openCell];
    }
    if ([self.currentFriends containsObject:cell.user.objectId]){
        [cell pressFriend];
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
#pragma mark - ImagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the images (based on your use case)
    self.profilePic.image = editedImage;
    self.setPic = editedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) didTapPhoto:(UITapGestureRecognizer *)sender{
    //TODO: Call method delegate
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}
- (PFFile *)getPFFileFromImage: (UIImage * _Nullable)image {
 
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
- (UIImage *)resizeI:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(300, 300, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
