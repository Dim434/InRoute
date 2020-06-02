//
//  MapView.m
//  InRoute
//
//  Created by Dmitry on 08.04.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "MapView.h"

@interface MapView ()
- (void)drawImage:(UIImage *)img;

- (void)drawShop:(NSDictionary *)shop;

- (void)stretchToSuperView:(UIView *)view;

- (void)clearShops;

- (void)drawLine;
@end

@implementation MapView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
- (void)stretchToSuperView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSString *formatTemplate = @"%@:|[view]|";
    for (NSString *axis in @[@"H", @"V"]) {
        NSString *format = [NSString stringWithFormat:formatTemplate, axis];
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:bindings];
        [view.superview addConstraints:constraints];
    }

}

- (void)drawImage:(UIImage *)img {
    if(self.image)
        [self.image removeFromSuperview];

    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y, img.size.width, img.size.height)];
    
    [image setImage:img];
    self.image = image;
    image.frame = CGRectMake(self.frame.origin.x,[UIScreen mainScreen].bounds.size.height / 4, img.size.width, img.size.height);
    [self addSubview:image];
    NSLog(@"%@",[self.lines count]);
    for (CAShapeLayer *layer in self.lines) {
            [layer removeFromSuperlayer];
        NSLog(@"Not drawing");
    }
    self.lines = [[NSMutableArray alloc] init];
}

- (void)clearShops {
    for (UIImageView *obj in self.shops) {
        [obj removeFromSuperview];
    }
    [self.shops removeAllObjects];
    NSLog(@"%d", 10);
    for (CAShapeLayer *layer in self.lines) {
            [layer removeFromSuperlayer];
        NSLog(@"Not drawing");
    }
    [self.lines removeAllObjects];
}

- (void)drawShop:(NSDictionary *)shop {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([[shop valueForKey:@"pos_x"] intValue] + self.image.frame.origin.x, [[shop valueForKey:@"pos_y"] intValue] + self.image.frame.origin.y, 16, 16)];
    [imageView setImage:[UIImage imageNamed:[NSString stringWithString:@"pointer.png"]]];
    [self addSubview:imageView];
    if (!self.shops) self.shops = [[NSMutableArray alloc] init];
    [self.shops addObject:imageView];

}
- (void)drawLine{
    if([self.shops count] >= 2){
        UIBezierPath *path = [UIBezierPath bezierPath];
        UIImageView * shoplast = [self.shops lastObject];
        UIImageView * shopPreLast = [self.shops objectAtIndex:([self.shops count] - 2)];
        
        [path moveToPoint:shoplast.center];
        [path addLineToPoint:shopPreLast.center];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor greenColor] CGColor];
        shapeLayer.lineWidth = 3.0;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [self.layer addSublayer:shapeLayer];
        [self.lines addObject:shapeLayer];
        NSLog(@"drawing");
    }
}
@end
