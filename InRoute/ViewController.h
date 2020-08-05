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
@protocol SearchControllerProtocol <NSObject>
@required
- (void)selectedData:(NSDictionary *)selected;
 
@end

@interface SearchPlaceController : UIViewController 
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *currentStores;
@property NSDictionary *returnedData;
@end

@interface InitViewController : UIViewController <CLLocationManagerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *routeButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,retain) CLLocationManager *locationManager;
@end

@interface ViewController : UIViewController <UIScrollViewDelegate, SearchControllerProtocol, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *tabbar;
@property (weak, nonatomic) IBOutlet MapView *mpView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *fromField;
@property (weak, nonatomic) IBOutlet UITextField *toField;
@property (weak, nonatomic) IBOutlet UIButton *stepButton;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeLabel;


@end

@interface SearchController :  UIViewController <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSDictionary *returnedData;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *currentShops;
@property (weak, nonatomic) id<SearchControllerProtocol> delegate;
@end
@interface AuthController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@interface AccountController : UIViewController 
@property (weak, nonatomic) IBOutlet UITextView *emailLabel;


@end
