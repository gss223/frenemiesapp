//
//  ChallengeDetailViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/21/21.
//

#import "ChallengeDetailViewController.h"

@interface ChallengeDetailViewController ()

@end

@implementation ChallengeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)calculateRelated:(NSArray *)tagArray withCounts:(NSArray *)countArray withTags:(NSArray *)yourTags withTotal:(NSArray *)totals{
    NSInteger counter = yourTags.count;
    for (NSString *tag in yourTags){
        NSInteger findInd= [tagArray indexOfObject:tag];
        
    }
    
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
