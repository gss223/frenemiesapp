//
//  LogViewController.h
//  frenemies
//
//  Created by Laura Yao on 7/23/21.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"
#import "Log.h"

NS_ASSUME_NONNULL_BEGIN

@interface LogViewController : UIViewController

@property (strong,nonatomic) Challenge *challenge;
@property (strong,nonatomic) Log *log;


@end

NS_ASSUME_NONNULL_END
