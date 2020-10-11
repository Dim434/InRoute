//
//  StockController.m
//  InRoute
//
//  Created by Dmitry on 28.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "StockController.h"
#import "Manager.h"
@interface StockController ()

@end

MyManager * manager;

@implementation StockController

- (void)viewDidLoad {
    [super viewDidLoad];
    manager = [MyManager sharedManager];
    [self.label_title setText:manager.stockTitle];
    [self.image setImage:manager.stockImage];
    [self.stockText setText:manager.stockText];
    [self.spashImage setImage:manager.spashImage];
    self.spashImage.contentMode = UIViewContentModeScaleAspectFit;

    self.spashImage.clipsToBounds = YES;
    self.spashImage.layer.cornerRadius = 20;
    self.spashImage.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.spashImage.layer.shadowRadius = 20;
    self.spashImage.layer.shadowRadius  = 1.5f;
    self.spashImage.layer.shadowColor   = [UIColor colorWithRed:176.f/255.f green:199.f/255.f blue:226.f/255.f alpha:1.f].CGColor;
    self.spashImage.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    self.spashImage.layer.shadowOpacity = 0.9f;
    self.spashImage.layer.masksToBounds = YES;

    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(self.spashImage.bounds, shadowInsets)];
    self.spashImage.layer.shadowPath    = shadowPath.CGPath;
    // Do any additional setup after loading the view.
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
