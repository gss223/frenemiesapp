//
//  GraphViewController.h
//  frenemies
//
//  Created by Laura Yao on 7/28/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface GraphViewController : UIViewController
@property (strong,nonatomic) PFUser *user;

@end

NS_ASSUME_NONNULL_END
