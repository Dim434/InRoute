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
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, img.size.width, img.size.height)];
    
    [image setImage:img];
    self.image = image;
    image.frame = CGRectMake(0,0, img.size.width, img.size.height);
    [self addSubview:image];
    NSLog(@"%lu",(unsigned long)[self.lines count]);
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
    self.path = nil;
    self.shapeLayer = nil;
}
- (void)clearImage{
    @autoreleasepool {
        
        [self.image removeFromSuperview];
        self.image = nil;
    }
}

- (void)drawShop:(NSDictionary *)shop {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([[shop valueForKey:@"pos_x"] intValue] + self.image.frame.origin.x, [[shop valueForKey:@"pos_y"] intValue] + self.image.frame.origin.y - 12, 16, 24)];
    if([[shop valueForKey:@"image_id"] class] == [NSNull class]){
        [imageView setImage:[UIImage imageNamed:@"pointer.png"]];
    }
    else{
        UIImage *img = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getShopImage/%d/", [[shop valueForKey:@"image_id"] intValue]]]]];
        [imageView setImage:img];
    }
    [self addSubview:imageView];
    if (!self.shops) self.shops = [[NSMutableArray alloc] init];
    [self.shops addObject:imageView];
    
}
- (void)drawLine{
    if(!self.path){
        self.path = [UIBezierPath bezierPath];
        self.shapeLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.shapeLayer];
        [self.lines addObject:self.shapeLayer];
    }
    if([self.shops count] >= 2){
        UIImageView * shoplast = [self.shops lastObject];
        UIImageView * shopPreLast = [self.shops objectAtIndex:([self.shops count] - 2)];
        UIImageView * firstView = [self.shops firstObject];
        if([self.shops count] == 2){
            self.man = [[UIImageView alloc] initWithFrame:CGRectMake(0,   0, 24, 24)];
            [self.man setImage:[UIImage imageNamed:@"icons8-ходьба-100.png"] ];
            [self addSubview:self.man];
        }
        
        
        [self.path moveToPoint:shoplast.center];
        [self.path addLineToPoint:shopPreLast.center];
        self.shapeLayer.path = [self.path CGPath];
        self.shapeLayer.strokeColor = [[UIColor colorWithRed:141.0f/255.0f green:191.0f/255.0f blue:90.0f/255.0f alpha:1.0f] CGColor];
        self.shapeLayer.lineWidth = 3.0;
        self.shapeLayer.fillColor = [[UIColor colorWithRed:141.0f/255.0f green:191.0f/255.0f blue:90.0f/255.0f alpha:1.0f] CGColor];
        self.shapeLayer.lineDashPattern = @[@5, @2];
        
        CAKeyframeAnimation *orbit = [CAKeyframeAnimation animation];
        orbit.keyPath = @"position";
        orbit.path = [[self.path bezierPathByReversingPath] CGPath];
        orbit.duration = 4;
        orbit.additive = NO;
        orbit.repeatCount = HUGE_VALF;
        orbit.calculationMode = kCAAnimationPaced;
        orbit.rotationMode = nil;
        
        [self.man.layer addAnimation:orbit forKey:@"orbit"];
        NSLog(@"drawing");
    }
}
@end
