//
//  ChallengeFindCell.m
//  frenemies
//
//  Created by Laura Yao on 7/21/21.
//

#import "ChallengeFindCell.h"
@interface ChallengeFindCell () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UILabel *challengeName;
@property (weak, nonatomic) IBOutlet UIImageView *challengeImage;
@property (weak, nonatomic) IBOutlet UIButton *addChallenge;
@property (weak, nonatomic) IBOutlet UIButton *viewDetails;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;


@end
static CGFloat const kBounceValue = 20.0f;
@implementation ChallengeFindCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.swipeView addGestureRecognizer:self.panRecognizer];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [self resetConstraintConstantsToZero:NO notifyDelegateDidClose:NO];
}
- (void)openCell {
  [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(void)setChallenge:(Challenge *)challenge{
    _challenge = challenge;
    self.challengeName.text = challenge.challengeName;
    self.challengeImage.layer.cornerRadius = 40;
    self.challengeImage.layer.masksToBounds = YES;
    [self.addChallenge setTitle:@"Add Challenge" forState:UIControlStateNormal];
    self.addChallenge.enabled = YES;
    PFFile *ImageFile =challenge.challengePic;
    [ImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.challengeImage.image = [UIImage imageWithData:imageData];
        }
    }];
}
- (IBAction)addChallengeAction:(id)sender {
    [self.delegate addChallengeButtonAction:self.challenge];
    [self.addChallenge setTitle:@"Added" forState:UIControlStateNormal];
    self.addChallenge.enabled = NO;
}
- (IBAction)viewDetailAction:(id)sender {
    [self.delegate detailButtonAction:self.challenge];
}
- (void)resetConstraintConstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate {
    if (notifyDelegate) {
      [self.delegate cellDidClose:self];
    }

  if (self.startingRightLayoutConstraintConstant == 0 &&
      self.contentViewRightConstraint.constant == 0) {
    return;
  }
  self.contentViewRightConstraint.constant = -kBounceValue;
  self.contentViewLeftConstraint.constant = kBounceValue;

  [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
    self.contentViewRightConstraint.constant = 0;
    self.contentViewLeftConstraint.constant = 0;
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
      self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
    }];
  }];
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate {
    if (notifyDelegate) {
      [self.delegate cellDidOpen:self];
    }

  if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
      self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
    return;
  }
  self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
  self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;

  [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
    self.contentViewRightConstraint.constant = [self buttonTotalWidth];

    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
      self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
    }];
  }];
}
- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.viewDetails.frame);
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
  switch (recognizer.state) {
      case UIGestureRecognizerStateBegan:
        self.panStartPoint = [recognizer translationInView:self.swipeView];
        self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        break;
      case UIGestureRecognizerStateChanged: {
        CGPoint currentPoint = [recognizer translationInView:self.swipeView];
        CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
        BOOL panningLeft = NO;
        if (currentPoint.x < self.panStartPoint.x) {
          panningLeft = YES;
        }

        if (self.startingRightLayoutConstraintConstant == 0) {
          if (!panningLeft) {
            CGFloat constant = MAX(-deltaX, 0); //3
            if (constant == 0) {
              [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:NO];
            } else { //5
              self.contentViewRightConstraint.constant = constant;
            }
          } else {
            CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]);
            if (constant == [self buttonTotalWidth]) {
              [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
            } else {
              self.contentViewRightConstraint.constant = constant;
            }
          }
        }
        else {
            CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX;
            if (!panningLeft) {
              CGFloat constant = MAX(adjustment, 0);
              if (constant == 0) {
                [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:NO];
              } else {
                self.contentViewRightConstraint.constant = constant;
              }
            } else {
              CGFloat constant = MIN(adjustment, [self buttonTotalWidth]);
              if (constant == [self buttonTotalWidth]) {
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
              } else {
                self.contentViewRightConstraint.constant = constant;
              }
            }
          }
          self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
        }
            break;
      case UIGestureRecognizerStateEnded:
        if (self.startingRightLayoutConstraintConstant == 0) {
          CGFloat halfOfButtonOne = CGRectGetWidth(self.addChallenge.frame) / 2;
          if (self.contentViewRightConstraint.constant >= halfOfButtonOne) {
            [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
          } else {
            [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES];
          }
        } else {
          CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.addChallenge.frame) + (CGRectGetWidth(self.viewDetails.frame) / 2);
          if (self.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) {
            [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
          } else {
            //Close
            [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES];
          }
        }
        break;
      case UIGestureRecognizerStateCancelled:
        if (self.startingRightLayoutConstraintConstant == 0) {
          [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES];
        } else {
          [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
        }
        break;
    default:
      break;
  }
}
- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
  float duration = 0;
  if (animated) {
    duration = 0.1;
  }

  [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    [self layoutIfNeeded];
  } completion:completion];
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
   return YES;
}
@end
