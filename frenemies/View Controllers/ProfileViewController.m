//
//  ProfileViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/14/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import <PFFacebookUtils.h>

@interface ProfileViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UIButton *facebookLink;
@property (strong, nonatomic) UIImage *setPic;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settheProfile];
    [self fixFacebookButton];
    UITapGestureRecognizer *photoTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPhoto:)];
        [self.profilePic addGestureRecognizer:photoTapGestureRecognizer];
        [self.profilePic setUserInteractionEnabled:YES];
    
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
    PFUser *user = [query findObjects][0];
    self.nameField.text = user[@"name"];
    self.username.text = user.username;
    PFFile *userImageFile = user[@"profilePic"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.profilePic.image = [UIImage imageWithData:imageData];
        }
    }];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the images (based on your use case)
    self.profilePic.image = editedImage;
    self.setPic = editedImage;
    
    //[self sendProfile:self.author.objectId withImage:[self getPFFileFromImage:[self resizeI:editedImage withSize:editedImage.size]]];
    
    
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
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
      [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:@[@"public_profile", @"email",@"user_friends"] block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
          NSLog(@"Woohoo, user is linked with Facebook!");
        }
      }];
    }
    else{
        [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
          if (succeeded) {
            NSLog(@"The user is no longer associated with their Facebook account.");
          }
        }];
    }

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
