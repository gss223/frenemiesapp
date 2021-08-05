//
//  LogViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/23/21.
//

#import "LogViewController.h"
#import "Gallery.h"

@interface LogViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logImage;
@property (weak, nonatomic) IBOutlet UILabel *units;
@property (weak, nonatomic) IBOutlet UITextField *logCaption;
@property (weak, nonatomic) IBOutlet UITextField *logUnit;
@property (weak, nonatomic) IBOutlet UIStepper *stepUnit;
@property (nonatomic,strong) UIImage *overallImage;

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *photoTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPhoto:)];
    [self.logImage addGestureRecognizer:photoTapGestureRecognizer];
    [self.logImage setUserInteractionEnabled:YES];
    [self setUpView];
}
-(void)setUpView{
    self.stepUnit.value= 0;
    self.units.text = [self.challenge.unitChosen stringByAppendingString:@"(s)"];
    
}
- (IBAction)unitFieldChange:(id)sender {
    NSUInteger currVal = [self.logUnit.text intValue];
    self.stepUnit.value = currVal;
}
- (IBAction)unitDidChange:(id)sender {
    NSUInteger currVal = [self.logUnit.text intValue];
    self.stepUnit.value = currVal;
}
- (IBAction)valueDidChange:(UIStepper *)sender {
    NSUInteger value= sender.value;
    self.logUnit.text= [NSString stringWithFormat:@"%02lu",value];
}
- (IBAction)addButtonAction:(id)sender {
    if (self.overallImage == nil){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Field"
            message:@"Please add an image."
            preferredStyle:(UIAlertControllerStyleAlert)];
        // create a cancel action
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
            handler:^(UIAlertAction * _Nonnull action) {
        }];
        // add the cancel action to the alertController
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
    else{
        UIImage *sendImage = self.overallImage;
        NSString *sendCaption = self.logCaption.text;
        NSNumber *sendUnit = [NSNumber numberWithInt:[self.logUnit.text intValue]];
        [self clearData];
        [Gallery postGallery:sendImage withCaption:sendCaption withChallengeId:self.challenge.objectId withUnit:sendUnit withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
        }];
    }
}

-(void)clearData{
    self.logImage.image = nil;
    self.stepUnit.value = 0;
    self.logCaption.text = @"";
    self.logUnit.text = @"0";
    self.overallImage = nil;
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - ImagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the images (based on your use case)
    self.logImage.image = editedImage;
    self.overallImage = [self resizeI:editedImage withSize:[editedImage size]];
    
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

@end
