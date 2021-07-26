//
//  GalleryCell.m
//  frenemies
//
//  Created by Laura Yao on 7/26/21.
//

#import "GalleryCell.h"

@implementation GalleryCell
-(void)setGallery:(Gallery *)gallery{
    _gallery = gallery;
    PFFile *imageFile = gallery.logImage;
    [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.galleryImage.image = [UIImage imageWithData:imageData];
        }
    }];
    
}

@end
