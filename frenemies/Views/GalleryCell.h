//
//  GalleryCell.h
//  frenemies
//
//  Created by Laura Yao on 7/26/21.
//

#import <UIKit/UIKit.h>
#import "Gallery.h"

NS_ASSUME_NONNULL_BEGIN

@interface GalleryCell : UICollectionViewCell
@property (strong,nonatomic) Gallery *gallery;
@property (weak, nonatomic) IBOutlet UIImageView *galleryImage;

@end

NS_ASSUME_NONNULL_END
