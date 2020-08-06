//
//  ViewController.m
//  InRoute
//
//  Created by Admin on 24/03/2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "ViewController.h"
#import "MapView.h"
#import "QRCodeReaderViewController.h"
NSArray *shops;

NSDictionary *from, *to;
NSDictionary *selected;
bool isFrom=true;
NSMutableArray *way;
NSMutableArray *shopsWay;
int curShop = 0;
bool changedData = false;
int curStore = 1;
NSArray* stores;
NSString * account_session = @"";
NSString * account_email = @"";
NSString * storeName = @"";
NSString * category = nil;
float getDistance(float x1, float y1, float x2, float y2){
    return sqrtf((x1 - x2)* (x1 - x2) + (y1 - y2)*(y1 - y2));
}
@interface SearchPlaceController ()

@end

@interface InitViewController ()

@end

@interface ViewController ()
- (void)initMapData;
@end

@interface SearchController ()
- (void)initData;
@end

@interface AuthController ()

@end

@interface AccountController ()

@end

@implementation InitViewController

- (NSDictionary *)getNearest{
    id data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/getListOfStores/"]];
    NSLog(@"ffff");
    stores = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *Nearest = stores[0];
    for (NSDictionary *point in stores) {
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
    curStore = [[point valueForKey:@"id"] intValue];
    [self.locationManager stopUpdatingLocation];
    
}

- (IBAction)searchPlace:(UITextField *)sender {
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchPlaceController"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goToMap:(UIButton *)sender {
    storeName = self.textField.text;
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    // [self addChildViewController:vc];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

@implementation SearchPlaceController
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
    [self.navigationItem setTitle:@"Выберите магаизин"];
    id data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/getListOfStores/"]];
    NSLog(@"ffff");
    stores = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *arr = [[NSArray alloc] initWithArray:stores];
    NSLog(@"%@", [[arr objectAtIndex:0] valueForKey:@"id"]);
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.tableView.dataSource = self;
    self.currentStores = [[NSMutableArray alloc] initWithArray:stores];
    self.tableView.tableFooterView = [UIView new];
    [self.tabBarController setSelectedIndex:0];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    return [self.currentStores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    };
    NSDictionary *shop = [self.currentStores objectAtIndex:indexPath.row];
    cell.textLabel.text = [shop valueForKey:@"title"];
    return cell;
}
- (IBAction)categorySelect:(UIButton *)sender {
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    NSString* title = sender.titleLabel.text;
    NSLog(@"%@", title);
    if ([title isEqualToString:@"University"]){
        category = @"университеты";
        NSLog(@"U");
        for (int i = 0; i < [self.currentStores count]; i++) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            
        }
        [self.currentStores removeAllObjects];
        int cnt = 0;
        for (NSDictionary *obj in stores) {
            if ([[[obj valueForKey:@"category"] lowercaseString] isEqualToString:@"университеты"]) {
                [self.currentStores addObject:obj];
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:cnt inSection:0]];
                cnt++;
            }
        }
    }
    else if([title isEqualToString:@"Shopping Center"]){
        NSLog(@"SC");
        category = @"торговые центры";
        for (int i = 0; i < [self.currentStores count]; i++) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            
        }
        [self.currentStores removeAllObjects];
        int cnt = 0;
        for (NSDictionary *obj in stores) {
            NSLog(@"%@", [[obj valueForKey:@"category"] lowercaseString]);
            if ([[[obj valueForKey:@"category"] lowercaseString] isEqualToString:@"торговые центры"]) {
                [self.currentStores addObject:obj];
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:cnt inSection:0]];
                cnt++;
            }
        }
        
    }
    else if([title isEqualToString:@"Business Center"]){
        category = @"бизнес-центры";
        NSLog(@"BC");
        for (int i = 0; i < [self.currentStores count]; i++) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            
        }
        [self.currentStores removeAllObjects];
        int cnt = 0;
        for (NSDictionary *obj in stores) {
            if ([[[obj valueForKey:@"category"] lowercaseString] isEqualToString:@"бизнес-центры"]) {
                [self.currentStores addObject:obj];
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:cnt inSection:0]];
                cnt++;
            }
        }
        
    }
    else if([title isEqualToString:@"Park"]){
        category = @"парки";
        NSLog(@"P");
        for (int i = 0; i < [self.currentStores count]; i++) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            
        }
        [self.currentStores removeAllObjects];
        
        int cnt = 0;
        for (NSDictionary *obj in stores) {
            if ([[[obj valueForKey:@"category"] lowercaseString] isEqualToString:@"парки"]) {
                [self.currentStores addObject:obj];
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:cnt inSection:0]];
                cnt++;
            }
        }
        
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.returnedData = [self.currentStores objectAtIndex:indexPath.row];
    curStore = [[[self.currentStores objectAtIndex:indexPath.row] valueForKey:@"id"] intValue];
    storeName = [[self.currentStores objectAtIndex:indexPath.row] valueForKey:@"title"];
    InitViewController *vc = (InitViewController *) self.presentingViewController.childViewControllers.firstObject;
    if(self.delegate != nil){
        [self.delegate initMapData];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:^void {
            [vc.textField setText:[[self.currentStores objectAtIndex:indexPath.row] valueForKey:@"title"]];
            
        }];
    
    
    }
}

- (void)searchBar:(UISearchBar *_Nonnull)searchBar textDidChange:(NSString *_Nonnull)searchText {
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.currentStores count]; i++) {
        [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
    }
    [self.currentStores removeAllObjects];
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    int cnt = 0;
    for (NSDictionary *obj in stores) {
        if ([[[obj valueForKey:@"title"] lowercaseString] hasPrefix:[searchText lowercaseString]]
            && [[[obj valueForKey:@"category"] lowercaseString] containsString:category]) {
            [self.currentStores addObject:obj];
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:cnt inSection:0]];
            cnt++;
        }
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}

@end

@implementation ViewController
- (void)initData {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    account_session = [prefs valueForKey:@"session_inroute"];
    account_email = [prefs valueForKey:@"email_inroute"];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getListOfShops/%d/", curStore]]];
    shops = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

- (void)initMapData {
    [self initData];
    [self.storeLabel setTitle:storeName forState:UIControlStateNormal];
    self.stepButton.layer.cornerRadius = 38 / 2.0f;
    [self.stepButton.layer setShadowOffset:CGSizeMake(5, 5)];
    [self.stepButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.stepButton.layer setShadowOpacity:0.5];
    self.tabbar.delegate = self;
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getListOfShops/%d/", curStore]]];
    NSDictionary *val = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] objectAtIndex:0];
    UIImage *img = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%d/", [[val valueForKey:@"section_id"] intValue]]]]];
    NSLog(@"%@", [NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%d/", [[val valueForKey:@"section_id"] intValue] ]);
    MapView *mpView = [[MapView alloc] init];
    if(self.mpView){
        [self.mpView clearShops];
        [self.mpView clearImage];
    }
    self.mpView = mpView;
    self.mpView.frame = CGRectMake(0, 0, MAX(self.scrollView.frame.size.width, img.size.width), MAX(self.scrollView.frame.size.height, img.size.height));
    
    [self.scrollView addSubview:mpView];
    double scaleF = self.scrollView.frame.size.width / img.size.width;
    
    NSLog(@"Float: %f, %f, %f", scaleF, img.size.width, img.size.height);
    self.mpView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    self.mpView.center = CGPointMake(self.scrollView.frame.size.width / 2,
                                     self.scrollView.frame.size.height / 2 - img.size.height / 2);
    
    self.mpView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleF, scaleF);
    
    [mpView drawImage:img];
    for (NSDictionary *shop in shops) {
        if ([[shop valueForKey:@"section_id"] intValue] == [[val valueForKey:@"section_id"] intValue] ) {
            [self.mpView drawShop:shop];
        }
    }
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setClipsToBounds:YES];
    self.scrollView.minimumZoomScale = scaleF;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initMapData];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mpView;
}

- (UIView *)viewForZooming:(UIScrollView *)scrollView {
    return self.mpView;
}
- (IBAction)changePlace:(id)sender {
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    SearchPlaceController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchPlaceController"];
    // [self addChildViewController:vc];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    
}

//- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    __auto_type subview = [scrollView subviews].firstObject;
//    if (subview == nil) {
//        return;
//    }
//    
//    __auto_type offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 5, 0.0);
//    __auto_type offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 5, 0.0);
//    subview.center = CGPointMake(offsetX, offsetY);
//}

- (IBAction)account:(id)sender {
    if(!account_session )
        account_session = @"";
    if([account_session isEqualToString:@""]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AuthController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AuthController"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AccountController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AccountController"];
        [self presentViewController:vc animated:YES completion:nil];
    }
}


- (IBAction)routeMap:(UIButton *)sender {
    if (from != nil && to != nil) {
        if (way == nil || changedData) {
            changedData = false;
            [self.mpView clearShops];
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getRoute/%@/%@/", [from valueForKey:@"id"], [to valueForKey:@"id"]]]];
            way = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil][1]];
            if([way count] == 0){
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                               message:@"Извините, путь между этими магазинами еще не проложен, наши сотрудники делают все возможное, чтобы исправить эту оплошность"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                way = nil;
                return;
            }
            shopsWay = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil][0]];
            curShop = 0;
            UIImage *img = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%@/", [[shopsWay objectAtIndex:curShop] valueForKey:@"section_id"]]]]];
            MapView *mpView = [[MapView alloc] init];
            self.mpView = mpView;
            self.mpView.frame = CGRectMake(0, 0, MAX(self.scrollView.frame.size.width, img.size.width), MAX(self.scrollView.frame.size.height, img.size.height));
            for (UIView *view in self.scrollView.subviews) {
                [view removeFromSuperview];
            }
            [self.scrollView addSubview:mpView];
            double scaleF = self.scrollView.frame.size.width / img.size.width;
            NSLog(@"%f", scaleF);
            self.mpView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
            self.mpView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleF, scaleF);
            self.mpView.center = CGPointMake(self.scrollView.frame.size.width / 2,
                                             self.scrollView.frame.size.height / 2 - img.size.height / 2);
            
            [mpView drawImage:img];
            for (NSDictionary *obj in shopsWay) {
                if ([obj valueForKey:@"section_id"] == [[shopsWay objectAtIndex:curShop] valueForKey:@"section_id"]) {
                    [self.mpView drawShop:obj];
                    [self.mpView drawLine];
                }
            }
            NSDictionary *final = @{@"desc": @"Путь завершен!"};
            [way addObject:final];
            NSLog(@"fuck");
            [self.stepLabel setText:[[way objectAtIndex:0] valueForKey:@"desc"]];
            [way removeObjectAtIndex:0];
        } else {
            curShop++;
            if ([[shopsWay objectAtIndex:curShop] valueForKey:@"section_id"] != [[shopsWay objectAtIndex:(curShop - 1)] valueForKey:@"section_id"]) {
                UIImage *img = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%@/", [[shopsWay objectAtIndex:curShop] valueForKey:@"section_id"]]]]];
                MapView *mpView = [[MapView alloc] init];
                self.mpView = mpView;
                self.mpView.frame = CGRectMake(0, 0, MAX(self.scrollView.frame.size.width, img.size.width), MAX(self.scrollView.frame.size.height, img.size.height));
                
                [self.scrollView addSubview:mpView];
                double scaleF = self.scrollView.frame.size.width / img.size.width;
                NSLog(@"%f", scaleF);
                self.mpView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
                self.mpView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleF, scaleF);
                self.mpView.center = CGPointMake(self.scrollView.frame.size.width / 2,
                                                 self.scrollView.frame.size.height / 2 - img.size.height / 2);
                
                [mpView drawImage:img];
                NSLog(@"CUR: %d",[[[shopsWay objectAtIndex:curShop] valueForKey:@"section_id"] intValue]);
                for (NSDictionary *obj in way) {
                    NSLog(@"Smth %d", [[obj valueForKey:@"section_id"] intValue] );
                    if ([obj valueForKey:@"section_id"] == [[shopsWay objectAtIndex:curShop] valueForKey:@"section_id"]) {
                        [self.mpView drawShop:obj];
                        [self.mpView drawLine];
                    }
                }
            }
            [self.stepLabel setText:[[way objectAtIndex:0] valueForKey:@"desc"]];
            [way removeObjectAtIndex:0];
            if ([way count] == 0)
                way = nil;
        }
    }
}
- (IBAction)fromSelect:(id)sender {
    isFrom=true;
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    SearchController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchController"];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (IBAction)toFieldSelect:(id)sender {
    isFrom = false;
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    SearchController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchController"];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (void)selectedData:(NSDictionary*)selected{
    
    if(isFrom == true){
        from = selected;
        NSLog(@"%@",[selected valueForKey:@"title"]);
        [self.fromField setText:[selected valueForKey:@"title"]  ];
        
    }
    else{
        to = selected;
        [self.toField setText:[selected valueForKey:@"title"]];
    }
}

@end

@implementation SearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arr = [[NSArray alloc] initWithArray:shops];
    NSLog(@"%@", [[arr objectAtIndex:0] valueForKey:@"id"]);
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.tableView.dataSource = self;
    self.currentShops = [[NSMutableArray alloc] initWithArray:shops];
    self.tableView.tableFooterView = [UIView new];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    return [self.currentShops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    };
    NSDictionary *shop = [self.currentShops objectAtIndex:indexPath.row];
    cell.textLabel.text = [shop valueForKey:@"title"];
    return cell;
}
- (void)OnDoneBlock {
    if ([self.delegate respondsToSelector:@selector(selectedData:)]) {
        [self.delegate selectedData:selected];
    }
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.returnedData = [self.currentShops objectAtIndex:indexPath.row];
    selected = self.returnedData;
    [self OnDoneBlock];
    
}

- (void)searchBar:(UISearchBar *_Nonnull)searchBar textDidChange:(NSString *_Nonnull)searchText {
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.currentShops count]; i++) {
        [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
    }
    [self.currentShops removeAllObjects];
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    int cnt = 0;
    for (NSDictionary *obj in shops) {
        if ([[[obj valueForKey:@"title"] lowercaseString] hasPrefix:[searchText lowercaseString]]) {
            [self.currentShops addObject:obj];
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:cnt inSection:0]];
            cnt++;
        }
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}

@end

@implementation AuthController

- (void)viewDidLoad{
    NSLog(@"loaded");
    [super viewDidLoad];
}
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
- (IBAction)loginButton:(id)sender {
    [self.view endEditing:YES];
    __block bool dismisss = false;
    NSString * email = self.emailField.text;
    NSString * password = self.passwordField.text;
    if(password.length < 8){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                       message:@"В пароле меньше 8 символов"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
         
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if(![self validateEmailWithString:email]){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                       message:@"Не правильно введен email"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
         
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/login/"]];
    
    NSString *userUpdate =[NSString stringWithFormat:@"email=%@&password=%@",email,password, nil];
    
    //create the Method "GET" or "POST"
    
    //Convert the String to Data
    
    //Apply the data to the body
    [request setHTTPMethod:@"POST"];
    
    //Pass The String to server(YOU SHOULD GIVE YOUR PARAMETERS INSTEAD OF MY PARAMETERS)
    
    //Check The Value what we passed
    NSLog(@"the data Details is =%@", userUpdate);
    
    //Convert the String to Data
    NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
    
    //Apply the data to the body
    [request setHTTPBody:data1];
    
    //Create the response and Error
    NSError *err;
    NSURLResponse *response;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSDictionary *res = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]];
    
    //This is for Response
    NSLog(@"got response==%@", res);
    if(res && [res objectForKey:@"key"])
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[res objectForKey:@"key"] forKey:@"session_inroute"];
        [prefs setObject:email forKey:@"email_inroute"];
        account_session = [res objectForKey:@"key"];
        account_email = email;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSLog(@"Error");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Неправильный логин/пароль"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    if(dismisss)
        [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)registerButton:(id)sender {
    [self.view endEditing:YES];
    __block bool dismisss = false;
    NSString * email = self.emailField.text;
    NSString * password = self.passwordField.text;
    if(password.length < 8){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                       message:@"В пароле меньше 8 символов"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
         
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if(![self validateEmailWithString:email]){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                       message:@"Не правильно введен email"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
         
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/register/"]];
    
    NSString *userUpdate =[NSString stringWithFormat:@"email=%@&password=%@",email,password, nil];
    
    //create the Method "GET" or "POST"
    
    //Convert the String to Data
    
    //Apply the data to the body
    [request setHTTPMethod:@"POST"];
    
    //Pass The String to server(YOU SHOULD GIVE YOUR PARAMETERS INSTEAD OF MY PARAMETERS)
    
    //Check The Value what we passed
    NSLog(@"the data Details is =%@", userUpdate);
    
    //Convert the String to Data
    NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
    
    //Apply the data to the body
    [request setHTTPBody:data1];
    
    //Create the response and Error
    NSError *err;
    NSURLResponse *response;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSDictionary *res = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]];
    
    //This is for Response
    NSLog(@"got response==%@", res);
    if(res && [res objectForKey:@"key"])
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[res objectForKey:@"key"] forKey:@"session_inroute"];
        [prefs setObject:email forKey:@"email_inroute"];
        account_session = [res objectForKey:@"key"];
        account_email = email;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSLog(@"Error");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Email уже занят"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    if(dismisss)
        [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end

@implementation AccountController

- (void)viewDidLoad{
    if(account_session && account_email){
        [self.emailLabel setText:account_email];
    }
    
}
- (IBAction)qrLaunch:(id)sender {
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    QRCodeReaderViewController *vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
    
    // Set the presentation style
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Define the delegate receiver
    vc.delegate = self;
    
    // Or use blocks
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"%@", resultAsString);
        [self sendQRcode:resultAsString];
        [vc dismissViewControllerAnimated:YES completion:NULL];
    }];
    [self presentViewController:vc animated:YES completion:NULL];
}
- (void)sendQRcode:(NSString *)qrValue{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/QRSend/"]];
    
    NSString *userUpdate =[NSString stringWithFormat:@"session=%@&value=%@", account_session, qrValue, nil];
    
    //create the Method "GET" or "POST"
    
    //Convert the String to Data
    
    //Apply the data to the body
    [request setHTTPMethod:@"POST"];
    
    //Pass The String to server(YOU SHOULD GIVE YOUR PARAMETERS INSTEAD OF MY PARAMETERS)
    
    //Check The Value what we passed
    NSLog(@"the data Details is =%@", userUpdate);
    
    //Convert the String to Data
    NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
    
    //Apply the data to the body
    [request setHTTPBody:data1];
    
    //Create the response and Error
    NSError *err;
    NSURLResponse *response;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSDictionary *res = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]];
    
    //This is for Response
    NSLog(@"got response==%@", res);
    if(res && [res objectForKey:@"result"])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:@"Успешно зарегестрирован код"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSLog(@"Error");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Уже есть в базе данных"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    
}
- (IBAction)logout:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"" forKey:@"session_inroute"];
    [prefs setObject:@"" forKey:@"email_inroute"];
    account_email = @"";
    account_session = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
