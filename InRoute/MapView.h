//
//  MapView.h
//  InRoute
//
//  Created by Dmitry on 08.04.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapView : UIView
@property(weak, nonatomic) IBOutlet UIImageView *image;
@property NSMutableArray *shops;
@property NSMutableArray *lines;

- (void)drawImage:(UIImage *)img;

- (void)drawShop:(NSDictionary *)shop;

- (void)stretchToSuperView:(UIView *)view;

- (void)clearShops;

- (void)drawLine;
@end

NS_ASSUME_NONNULL_END
