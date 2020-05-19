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


@interface SearchPlaceController : UIViewController 
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *currentStores;
@property NSDictionary *returnedData;
@end

@interface InitViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *routeButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,retain) CLLocationManager *locationManager;
@end

@interface ViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *tabbar;
@property (weak, nonatomic) IBOutlet MapView *mpView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;


@end
@interface SearchController :  UIViewController <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSDictionary *returnedData;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *currentShops;
@end

@interface InfoController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *shopTitle;
@property NSDictionary *obj;
@end
