//
//  GalleryViewController.m
//  frenemies
//
//  Created by Laura Yao on 8/3/21.
//

#import "GalleryViewController.h"
#import <DateTools/DateTools.h>

@interface GalleryViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *galleryImage;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    [navigationBar setTranslucent:YES];
}
-(void)setUpView{
    self.nameLabel.text = self.gallery.author[@"name"];
    self.usernameLabel.text = self.gallery.author.username;
    self.captionLabel.text = self.gallery.logCaption;
    self.dateLabel.text = [self.gallery.createdAt shortTimeAgoSinceNow];
    self.userImage.layer.cornerRadius = 25;
    self.userImage.layer.masksToBounds = YES;
    PFFile *ImageFile =self.gallery.logImage;
    [ImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.galleryImage.image = [UIImage imageWithData:imageData];
        }
    }];
    PFFile *userImageFile =self.gallery.author[@"profilePic"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.userImage.image = [UIImage imageWithData:imageData];
        }
    }];
}

@end
