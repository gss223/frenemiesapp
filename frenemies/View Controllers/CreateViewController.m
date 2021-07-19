//
//  CreateViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/13/21.
//

#import "CreateViewController.h"
#import <Parse/Parse.h>
#import "FriendCell.h"
#import "TagCell.h"
#import <CCDropDownMenus/CCDropDownMenus.h>
#import "Challenge.h"

@interface CreateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,CCDropDownMenuDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *challengePic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *challengeName;
@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTime;
@property (weak, nonatomic) IBOutlet UITextView *challengeDescription;
@property (nonatomic, strong) NSArray *friendArray;
@property (nonatomic, strong) NSArray *taggingArray;
@property (nonatomic, strong) NSArray *dropdownArray;
@property (weak, nonatomic) IBOutlet UIView *dropdownView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic,strong) NSString *unitChose;
@property (nonatomic, strong) NSMutableArray *selectedTags;
@property (nonatomic,strong) NSMutableArray *selectedFriends;
@property (nonatomic,strong) NSArray *myFriends;

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsMultipleSelection = true;
    self.dropdownArray = [NSArray arrayWithObjects:@"mile",@"meter",@"liter",@"second",@"day",@"cup",@"meal",@"minute",nil];
    self.taggingArray = [NSArray arrayWithObjects:@"health", @"fitness",@"food",@"academic",@"social",@"fashion",@"other",nil];
    ManaDropDownMenu *menu = [[ManaDropDownMenu alloc] initWithFrame:self.dropdownView.frame title:@"Units"];
        menu.delegate = self;
        menu.numberOfRows = self.dropdownArray.count;
        menu.textOfRows = self.dropdownArray;
        [self.contentView addSubview:menu];
    [self setupFriend];
    self.challengeDescription.delegate = self;
    self.challengeDescription.text = @"Challenge Description";
    self.challengeDescription.textColor = [UIColor systemGrayColor];
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"Friend"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object==nil){
            PFObject *friend = [PFObject objectWithClassName:@"Friend"];
            friend[@"userId"] =[PFUser currentUser].objectId;
            friend[@"friendArray"] = [NSMutableArray array];
            [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if (succeeded) {
                // The object has been saved.
              } else {
                // There was a problem, check error.description
              }
            }];
        }
        else{
            self.myFriends = object[@"friendArray"];
            if (self.myFriends!=nil && self.myFriends.count>0){
                PFQuery *query2 = [PFUser query];
                [query2 whereKey:@"objectId" containedIn:self.myFriends];
                [query2 findObjectsInBackgroundWithBlock:^(NSArray <PFUser *> * _Nullable objects, NSError * _Nullable error) {
                    self.friendArray = objects;
                    [self.tableView reloadData];
                }];
            }
        }
    }];
}
- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index {
    self.unitChose = self.dropdownArray[index];
}
- (IBAction)createAction:(id)sender {
    NSString *challengeName = self.challengeName.text;
    NSString *challengeDescription = self.challengeDescription.text;
    BOOL puborpriv = self.publicSwitch.isOn;
    NSDate *timeStart = self.startTime.date;
    NSDate *timeEnd = self.endTime.date;
    //NSString *unit = self.unitChose;
    NSLog(@"%@",self.selectedTags);
    if(self.selectedFriends ==nil){
        self.selectedFriends = [NSMutableArray array];
    }
    NSNumber *boolForUserInfo = @(puborpriv);
    NSArray *challengeParams =[NSArray arrayWithObjects:challengeName,challengeDescription,boolForUserInfo,timeStart,timeEnd,self.unitChose,self.selectedTags,self.selectedFriends, nil];
    UIImage *neededImage =[self resizeI:self.challengePic.image withSize:(self.challengePic.image.size)];
    [self clearAllFields];
    [self reloadInputViews];
    //NSMutableArray *challengeParams = [NSMutableArray arrayWithObjects:challengeName,challengeDescription,puborpriv,timeStart,timeEnd,self.unitChose,self.selectedTags,self.selectedFriends,nil];
    [Challenge postChallenge:neededImage withOtherinfo:challengeParams withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            NSLog(@"successfully created challenge");
            
        }
        else{
            NSLog(@"done");
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
-(void)clearAllFields{
    self.challengePic.image = nil;
    self.challengeDescription.text =nil;
    self.challengeDescription.text = @"Challenge Description";
    self.challengeDescription.textColor = [UIColor systemGrayColor];
    self.challengeName.text= nil;
    self.endTime.date = [NSDate date];
    self.startTime.date = [NSDate date];
    self.unitChose = nil;
    self.selectedTags = nil;
    self.selectedFriends = nil;
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in selectedItems){
        [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
        UICollectionViewCell *cell= [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColor= [UIColor clearColor];
    }
    NSArray *selectedF = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedF){
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    }
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
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.friendArray.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendCell* cell = (FriendCell *) [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    cell.user = self.friendArray[indexPath.row];
    return cell;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //NSArray *taggingArray =[NSArray arrayWithObjects:@"health",@"fitness",@"food",@"academic",@"social",@"fashion",@"other",nil];
    return self.taggingArray.count;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagCell" forIndexPath:indexPath];
    //NSArray *taggingArray =[NSArray arrayWithObjects:@"health", @"fitness",@"food",@"academic",@"social",@"fashion",@"other",nil];
    cell.tagName.text = self.taggingArray[indexPath.row];
    //NSLog(taggingArray[indexPath.row]);
    cell.contentView.layer.cornerRadius = 5.0;
    cell.contentView.layer.masksToBounds = true;
    cell.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    cell.contentView.layer.borderWidth = 1;
    return cell;
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSArray *taggingArray =[NSArray arrayWithObjects:@"health", @"fitness",@"food",@"academic",@"social",@"fashion",@"other",nil];
    if (self.selectedTags ==nil){
        self.selectedTags = [NSMutableArray array];
    }
    if (self.selectedTags.count<3){
        [self.selectedTags addObject:self.taggingArray[indexPath.row]];
        UICollectionViewCell *cell= [collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColor= [UIColor greenColor];
    }
    else{
        [self.collectionView deselectItemAtIndexPath:indexPath animated:true];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.selectedTags removeObject:self.taggingArray[indexPath.row]];
    UICollectionViewCell *cell= [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor= [UIColor clearColor];
}
-(void) textViewDidBeginEditing:(UITextView *)textView{
    if (textView.textColor == [UIColor systemGrayColor]){
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length<=0){
        textView.text = @"Challenge Description";
        textView.textColor = [UIColor systemGrayColor];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectedFriends ==nil){
        self.selectedFriends = [NSMutableArray array];
    }
    [self.selectedFriends addObject:self.myFriends[indexPath.row]];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.selectedFriends removeObject:self.myFriends[indexPath.row]];
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
