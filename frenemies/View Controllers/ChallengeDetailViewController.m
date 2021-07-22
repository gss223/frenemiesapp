//
//  ChallengeDetailViewController.m
//  frenemies
//
//  Created by Laura Yao on 7/21/21.
//

#import "ChallengeDetailViewController.h"
#import <math.h>

@interface ChallengeDetailViewController ()

@end

@implementation ChallengeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)calculateRelated:(NSArray *)tagArray withCounts:(NSArray *)countArray withTags:(NSArray *)yourTags withTotal:(NSNumber *)total{
    float counter = [[NSNumber numberWithInt:yourTags.count] floatValue];
    float n = [[NSNumber numberWithInt:yourTags.count] floatValue];
    float totalRelTagVal = 0;
    for (NSString *tag in yourTags){
        NSInteger findInd= [tagArray indexOfObject:tag];
        NSNumber *countofTag = countArray[findInd];
        float tdf = counter/(n*(n+1)/2);
        float df = [countofTag floatValue];
        float totalN = [total floatValue];
        float idf = logf(totalN/(df+1));
        float relTagVal = tdf*idf;
        totalRelTagVal+=relTagVal;
        counter-=1;
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
