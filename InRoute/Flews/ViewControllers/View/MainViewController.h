//
//  ViewController.h
//  InRoute
//
//  Created by Admin on 24/03/2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import <CoreLocation/CoreLocation.h>
#import "SearchPlaceViewController.h"
#import "SearchController.h"
@import WebKit;
@import AuthenticationServices;



@interface MyScrollView : UIScrollView
@property (nonatomic) double scaleF;
@property (nonatomic) MapView *mpView;

- (CGRect)zoomRect:(CGFloat)scale center:(CGPoint)center;
- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer;

@end


@interface MainViewController : UIViewController <UIScrollViewDelegate, SearchControllerProtocol, ShopViewControllerProtocol, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet MapView *mpView;
@property (weak, nonatomic) IBOutlet MyScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *fromField;
@property (weak, nonatomic) IBOutlet UITextField *toField;
@property (weak, nonatomic) IBOutlet UIButton *stepButton;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UIButton *storeLabel;
@property (weak, nonatomic) IBOutlet UIButton *ppdf;
@property double scaleF;

@end


