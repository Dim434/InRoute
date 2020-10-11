//
//  InitViewController.h
//  InRoute
//
//  Created by Dmitry on 16.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

@interface InitViewController : UIViewController <CLLocationManagerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *routeButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,retain) CLLocationManager *locationManager;

@end

NS_ASSUME_NONNULL_END
