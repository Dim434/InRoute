//
//  StockController.h
//  InRoute
//
//  Created by Dmitry on 28.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StockController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *stockText;
@property (weak, nonatomic) IBOutlet UIImageView *spashImage;
- (void) setImage:(UIImage *)img gtitle:(NSString *)ttitle stockText:(NSString *)stocktext;

@end

NS_ASSUME_NONNULL_END
