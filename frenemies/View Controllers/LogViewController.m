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
    // Do any additional setup after loading the view.
}
-(void)setUpView{
    self.logUnit.text =[NSString stringWithFormat:@"%02lu",0];
    self.stepUnit.value= 0;
    self.units.text = [self.challenge.unitChosen stringByAppendingString:@"(s)"];
    
}
- (IBAction)valueDidChange:(UIStepper *)sender {
    NSUInteger currVal = [self.logUnit.text intValue];
    self.logUnit.text= [NSString stringWithFormat:@"%02lu",1+currVal];
    self.stepUnit.value = 1+currVal;
}
- (IBAction)addAction:(id)sender {
    [Gallery postGallery:self.overallImage withCaption:self.logCaption.text withChallengeId:self.challenge.objectId withUnit:[NSNumber numberWithInt:[self.logUnit.text intValue]] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            NSLog(@"gallery");
        }
    }];
    
}
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
