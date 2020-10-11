//
//  InitViewController.m
//  InRoute
//
//  Created by Dmitry on 16.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "InitViewController.h"
#import "Manager.h"
#import "MainViewController.h"
@import UserNotifications;

@interface InitViewController ()

@end

float getDistance(float x1, float y1, float x2, float y2){
    return sqrtf((x1 - x2)* (x1 - x2) + (y1 - y2)*(y1 - y2));
}

@implementation InitViewController

- (NSDictionary *)getNearest{
    
    id data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/getListOfStores/"]];
    NSLog(@"ffff");
    ((MyManager *)[MyManager sharedManager]).stores = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *Nearest = ((MyManager *)[MyManager sharedManager]).stores[0];
    for (NSDictionary *point in ((MyManager *)[MyManager sharedManager]).stores) {
        if(getDistance([[point valueForKey:@"pos_x"] floatValue], [[point valueForKey:@"pos_y"] floatValue], self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude) <getDistance([[Nearest valueForKey:@"pos_x"] floatValue], [[Nearest valueForKey:@"pos_y"] floatValue], self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude) ){
            Nearest = point;
        }
    }
    return Nearest;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // hide nav bar
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // enable slide-back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:
     (UNAuthorizationOptionAlert +
      UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // Enable or disable features based on authorization.
    }];
    self.routeButton.layer.cornerRadius = 5;
    self.routeButton.clipsToBounds = YES;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    NSDictionary *point = [self getNearest];
    NSLog(@"233");
    [self.textField setText:[point valueForKey:@"title"]];
    ((MyManager *)[MyManager sharedManager]).curStore = [[point valueForKey:@"id"] intValue];
    [self.locationManager stopUpdatingLocation];
    
}

- (IBAction)searchPlace:(UITextField *)sender {
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchPlaceController"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goToMap:(UIButton *)sender {
    ((MyManager *)[MyManager sharedManager]).storeName = self.textField.text;
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    // [self addChildViewController:vc];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
