//
//  SwipeUserCell.m
//  frenemies
//
//  Created by Laura Yao on 7/19/21.
//

#import "SwipeUserCell.h"

@interface SwipeUserCell () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;

@end
static CGFloat const kBounceValue = 20.0f;
@implementation SwipeUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
      self.panRecognizer.delegate = self;
    [self.swipeView addGestureRecognizer:self.panRecognizer];
    // Initialization code
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
- (void)setUser:(PFUser *)user {
    _user = user;
    self.username.text = user.username;
    self.nameField.text = user[@"name"];
    self.profilePic.layer.cornerRadius = 30;
    self.profilePic.layer.masksToBounds = YES;
    [self.addButton setTitle:@"Add Friend" forState:UIControlStateNormal];
    self.addButton.enabled = YES;
    PFFile *userImageFile = user[@"profilePic"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.profilePic.image = [UIImage imageWithData:imageData];
        }
    }];
}
- (IBAction)pressedFriend:(id)sender {
    [self.delegate addButtonAction:self.user];
    [self.addButton setTitle:@"Added" forState:UIControlStateNormal];
    self.addButton.enabled = NO;
}
-(void)pressFriend{
    [self.addButton setTitle:@"Added" forState:UIControlStateNormal];
    self.addButton.enabled = NO;
}
- (IBAction)clickedProfile:(id)sender {
    [self.delegate profileButtonAction:self.user];
}
- (void)resetConstraintConstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate {
    if (notifyDelegate) {
      [self.delegate cellDidClose:self];
    }

  if (self.startingRightLayoutConstraintConstant == 0 &&
      self.contentViewRightConstraint.constant == 0) {
    //Already all the way closed, no bounce necessary
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
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.profileButton.frame);
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
            CGFloat constant = MAX(-deltaX, 0);
            if (constant == 0) {
              [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:NO];
            } else {
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
          CGFloat halfOfButtonOne = CGRectGetWidth(self.addButton.frame) / 2;
          if (self.contentViewRightConstraint.constant >= halfOfButtonOne) {
            [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
          } else {
            [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES];
          }
        } else {
          CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.addButton.frame) + (CGRectGetWidth(self.profileButton.frame) / 2); //4
          if (self.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) {
            [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
          } else {
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


