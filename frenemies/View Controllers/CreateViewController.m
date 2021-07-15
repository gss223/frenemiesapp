//
//  CreateViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/13/21.
//

#import "CreateViewController.h"
#import <Parse/Parse.h>
#import "MKDropdownMenu.h"
#import "FriendCell.h"
#import "TagCell.h"
#import <CCDropDownMenus/CCDropDownMenus.h>

@interface CreateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,CCDropDownMenuDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *challengePic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *challengeName;
@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTime;
//@property (weak, nonatomic) IBOutlet MKDropdownMenu *dropdownMenu;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTime;
@property (weak, nonatomic) IBOutlet UITextView *challengeDescription;
@property (nonatomic, strong) NSArray *friendArray;
//@property (nonatomic, strong) NSArray *taggingArray;
@property (nonatomic, strong) NSArray *dropdownArray;
@property (weak, nonatomic) IBOutlet UIView *dropdownView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic,strong) NSString *unitChose;

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.dropdownArray = [NSArray arrayWithObjects:@"mile",@"meter",@"liter",@"second",@"day",@"cup",@"meal",@"minute",nil];
    ManaDropDownMenu *menu = [[ManaDropDownMenu alloc] initWithFrame:self.dropdownView.frame title:@"Units"];
        menu.delegate = self;
        menu.numberOfRows = self.dropdownArray.count;
        menu.textOfRows = self.dropdownArray;
        [self.contentView addSubview:menu];
    [self setupFriend];
    //[self setupTags];
    UITapGestureRecognizer *photoTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPhoto:)];
    [self.challengePic addGestureRecognizer:photoTapGestureRecognizer];
    [self.challengePic setUserInteractionEnabled:YES];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        CGFloat itemWidth = (self.collectionView.frame.size.width-layout.minimumInteritemSpacing*(4-1))/4;
        CGFloat itemHeight = itemWidth*0.3;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    // Do any additional setup after loading the view.
}
-(void) setupFriend{
    NSArray *myFriends = [PFUser currentUser][@"friends"];
    if (myFriends!=nil){
        PFQuery *query = [PFUser query];
        for (NSString *friend in myFriends){
            [query whereKey:@"objectId" equalTo:friend];
        }
        self.friendArray = [query findObjects];
    }
    [self.tableView reloadData];
}
- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index {
    self.unitChose = self.dropdownArray[index];
}
- (IBAction)createAction:(id)sender {
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the images (based on your use case)
    self.challengePic.image = editedImage;
    
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
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.friendArray.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendCell* cell = (FriendCell *) [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    cell.user = self.friendArray[indexPath.row];
    return cell;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *taggingArray =[NSArray arrayWithObjects:@"health",@"fitness",@"food",@"academic",@"social",@"fashion",@"other",nil];
    return taggingArray.count;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagCell" forIndexPath:indexPath];
    NSArray *taggingArray =[NSArray arrayWithObjects:@"health", @"fitness",@"food",@"academic",@"social",@"fashion",@"other",nil];
    cell.tagName.text = taggingArray[indexPath.row];
    //NSLog(taggingArray[indexPath.row]);
    cell.contentView.layer.cornerRadius = 5.0;
    cell.contentView.layer.masksToBounds = true;
    cell.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    cell.contentView.layer.borderWidth = 1;
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
