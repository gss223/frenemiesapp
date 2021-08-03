//
//  DoneViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/23/21.
//

#import "DoneViewController.h"
#import "Log.h"
#import <QuartzCore/QuartzCore.h>

@interface DoneViewController ()
@property (nonatomic,strong) NSMutableArray *logNumbers;
@property (nonatomic,strong) NSMutableArray *participants;
@property (nonatomic,strong) NSNumber *totalParticipants;
@property (nonatomic,strong) NSNumber *amount;
@property (nonatomic,strong) NSNumber *rank;
@property (nonatomic,strong) NSArray *logs;
@property (nonatomic,strong) Log *yourLog;
@property (weak, nonatomic) IBOutlet UIImageView *celebrateView;
@property (weak, nonatomic) IBOutlet UILabel *units;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitChose;
@property (weak, nonatomic) IBOutlet UILabel *partAmount;
@property (weak, nonatomic) IBOutlet UILabel *loggedTot;
@property (weak, nonatomic) IBOutlet UILabel *outOf;
@property (weak, nonatomic) IBOutlet UILabel *people;
@property (strong, nonatomic) IBOutlet UIView *stickerView;
@property (weak, nonatomic) IBOutlet UIImageView *challengeImage;
@property (weak, nonatomic) IBOutlet UILabel *challName;
@property (weak, nonatomic) IBOutlet UILabel *stickerUnits;
@property (weak, nonatomic) IBOutlet UILabel *stickerAmount;
@property (weak, nonatomic) IBOutlet UIImageView *trophyView;

@end

@implementation DoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkIfDataGone];
    [self getLogData];
    // Do any additional setup after loading the view.
}
-(void)getLogData{
    PFQuery *query = [PFQuery queryWithClassName:@"Log"];
    [query whereKey:@"challengeId" equalTo:self.challenge.objectId];
    [query includeKey:@"logger"];
    [query orderByDescending:@"unitAmount"];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Log *> * _Nullable objects, NSError * _Nullable error) {
        if (objects ==nil ||objects.count==0){
            [Log postLog:self.challenge.objectId withAmount:[NSNumber numberWithInt:0] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (error==nil){
                    NSLog(@"succesfully logged");
                }
            }];
            self.logNumbers = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:1]];
            self.participants = [NSMutableArray arrayWithObject:[PFUser currentUser]];
            self.totalParticipants = [NSNumber numberWithInt:1];
            self.amount =[NSNumber numberWithInt:0];
            self.rank =[NSNumber numberWithInt:1];
        }
        else{
            self.logs = objects;
            self.logNumbers = [NSMutableArray array];
            self.participants = [NSMutableArray array];
            self.totalParticipants = [NSNumber numberWithInt:objects.count];
            BOOL yourLogexists = false;
            int counter = 0;
            for (Log *log in self.logs){
                if ([log.logger.objectId isEqualToString:[PFUser currentUser].objectId] ){
                    yourLogexists = true;
                    self.amount = log.unitAmount;
                    self.yourLog = log;
                    self.rank = [NSNumber numberWithInt:(counter+1)];
                }
                [self.logNumbers addObject:log.unitAmount];
                [self.participants addObject:log.logger];
                counter +=1;
            }
            if (yourLogexists ==false){
                self.amount = [NSNumber numberWithInt:0];
                [Log postLog:self.challenge.objectId withAmount:[NSNumber numberWithInt:0] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded){
                        
                    }
                }];
                [self.logNumbers addObject:self.amount];
                [self.participants addObject:[PFUser currentUser]];
                self.totalParticipants = [NSNumber numberWithInt:[self.totalParticipants intValue]+1];
                self.rank = self.totalParticipants;
            }
        }
        
        [self setUpViews];
        
    }];
    
}
-(void) setUpViews{
    [self setUpStickerView];
    self.units.text = [self.amount stringValue];
    if ([self.amount intValue]!=1){
        self.unitChose.text = [self.challenge.unitChosen stringByAppendingString:@"s"];
    }
    else{
        self.unitChose.text = self.challenge.unitChosen;
    }
    self.rankLabel.text = [self.rank stringValue];
    self.partAmount.text = [self.totalParticipants stringValue];
    self.celebrateView.image = [UIImage imageNamed:@"celebrate"];
    [self fadeIn];
    
}
-(void)setUpStickerView{
    self.challName.text = self.challenge.challengeName;
    self.stickerAmount.text =[self.amount stringValue];
    if ([self.amount intValue]!=1){
        self.stickerUnits.text = [self.challenge.unitChosen stringByAppendingString:@"s"];
    }
    else{
        self.stickerUnits.text = self.challenge.unitChosen;
    }
    if ([self.rank intValue]==1){
        self.trophyView.image = [UIImage imageNamed:@"gold"];
    }
    else if ([self.rank intValue]==2){
        self.trophyView.image = [UIImage imageNamed:@"silver"];
    }
    else if([self.rank intValue]==3){
        self.trophyView.image = [UIImage imageNamed:@"bronze"];
    }
    else{
        self.trophyView.image = [UIImage imageNamed:@"badge"];
    }
    PFFile *ImageFile =self.challenge.challengePic;
    [ImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.challengeImage.image = [UIImage imageWithData:imageData];
            if (self.challengeImage.image ==nil){
                self.challengeImage.image = [UIImage imageNamed:@"celebrate"];
            }
            
        }
    }];
}
- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}
-(void)shareInstaImage{
    NSData *stickerImage = UIImagePNGRepresentation([self imageWithView:self.stickerView]);
    // Verify app can open custom URL scheme. If able,
      // assign assets to pasteboard, open scheme.
    NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share?source_application=com.my.app"];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

          // Assign background and sticker image assets to pasteboard
          NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundTopColor" : @"#636e72",
                                         @"com.instagram.sharedSticker.backgroundBottomColor" : @"#636e72",
                                         @"com.instagram.sharedSticker.stickerImage" : stickerImage}];
          NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
          // This call is iOS 10+, can use 'setItems' depending on what versions you support
          [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];

          [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
      } else {
          // Handle older app versions or app not installed case
      }
}
-(void)shareFBImage{
    NSString *appId = @"355670739456353";
    NSData *stickerImage = UIImagePNGRepresentation([self imageWithView:self.stickerView]);
    // Verify app can open custom URL scheme. If able,
      // assign assets to pasteboard, open scheme.
    NSURL *urlScheme = [NSURL URLWithString:@"facebook-stories://share"];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

          // Assign background and sticker image assets to pasteboard
        NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundTopColor" : @"#636e72",
                                       @"com.instagram.sharedSticker.backgroundBottomColor" : @"#636e72",
                                         @"com.facebook.sharedSticker.stickerImage" : stickerImage,
                                         @"com.facebook.sharedSticker.appID" : appId}];
          NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
          // This call is iOS 10+, can use 'setItems' depending on what versions you support
          [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];

          [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
      } else {
          // Handle older app versions or app not installed case
      }
}
-(void)fadeIn{
    [self.units setAlpha:0.0f];
    [self.unitChose setAlpha:0.0f];
    [self.rankLabel setAlpha:0.0f];
    [self.partAmount setAlpha:0.0f];
    [self.loggedTot setAlpha:0.0f];
    [self.outOf setAlpha:0.0f];
    [self.people setAlpha:0.0f];
    [UIView animateWithDuration:2.0f animations:^{
        [self.units setAlpha:1.0f];
        [self.unitChose setAlpha:1.0f];
        [self.rankLabel setAlpha:1.0f];
        [self.partAmount setAlpha:1.0f];
        [self.loggedTot setAlpha:1.0f];
        [self.outOf setAlpha:1.0f];
        [self.people setAlpha:1.0f];
    }];
}
-(void) checkIfDataGone{
    if (self.challenge.completed){
        [self removeUserData];
        [self removeLink];
    }
    else{
        [self removeLink];
        [self changeChallenge];
        [self removeUserData];
        [self removeStats];
        
    }
}
-(void) removeLink{
    PFQuery *query = [PFQuery queryWithClassName:@"LinkChallenge"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error==nil){
            if(object!=nil){
                NSString *LinkChallengeId = object.objectId;
                PFQuery *query2 = [PFQuery queryWithClassName:@"LinkChallenge"];
                [query2 getObjectInBackgroundWithId:LinkChallengeId block:^(PFObject * _Nullable linkChallenge, NSError * _Nullable error) {
                    NSMutableArray *challArray = linkChallenge[@"challengeArray"];
                    [challArray removeObject:self.challenge.objectId];
                    linkChallenge[@"challengeArray"] = challArray;
                    [linkChallenge saveInBackground];
                }];
            }
        }
    }];
}
-(void) removeUserData{
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject * _Nullable user, NSError * _Nullable error) {
        NSMutableArray *completeChall = user[@"completed"];
        if (completeChall ==nil){
            completeChall = [NSMutableArray array];
        }
        [completeChall addObject:self.challenge.objectId];
        user[@"completed"] = completeChall;
        [user saveInBackground];
    }];
    
}
-(void)removeStats{
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    [query getObjectInBackgroundWithId:@"YydWA5vGjZ" block:^(PFObject * _Nullable stat, NSError * _Nullable error) {
        NSMutableArray *ctArray = stat[@"countArray"];
        for (NSString *tag in self.challenge.tags){
            NSInteger findInd= [stat[@"tagArray"] indexOfObject:tag];
            ctArray[findInd] = [NSNumber numberWithInt:([ctArray[findInd] integerValue] - 1)];
        }
        NSNumber *total = stat[@"total"];
        total = [NSNumber numberWithInt:[total intValue]-1];
        stat[@"countArray"] = ctArray;
        stat[@"total"] = total;
        [stat saveInBackground];
    }];
}
-(void)changeChallenge{
    PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
    [query getObjectInBackgroundWithId:self.challenge.objectId block:^(PFObject * _Nullable chall, NSError * _Nullable error) {
        chall[@"completed"] = @YES;
        [chall saveInBackground];
    }];
}
- (IBAction)shareToInsta:(id)sender {
    [self shareInstaImage];
}
- (IBAction)shareToFB:(id)sender {
    [self shareFBImage];
}

@end
