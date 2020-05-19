//
//  ViewController.m
//  InRoute
//
//  Created by Admin on 24/03/2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "ViewController.h"
#import "MapView.h"

NSArray *shops;

NSDictionary *from, *to;
NSMutableArray *way;
NSMutableArray *shopsWay;
int curShop = 0;
bool changedData = false;
int curStore = 1;
float getDistance(float x1, float y1, float x2, float y2){
    return sqrtf((x1 - x2)* (x1 - x2) + (y1 - y2)*(y1 - y2));
}
@interface SearchPlaceController ()

@end

@interface InitViewController ()

@end

@interface ViewController ()

@end

@interface SearchController ()
- (void)initData;
@end

@interface InfoController ()
- (void)setObject:(NSDictionary *)obj;
@end

@implementation InitViewController

- (NSDictionary *)getNearest{
    id data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/getListOfStores/"]];
    NSLog(@"ffff");
    NSArray *stores = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *Nearest = stores[0];
    for (NSDictionary *point in stores) {
        if(getDistance([[point valueForKey:@"pos_x"] floatValue], [[point valueForKey:@"pos_y"] floatValue], self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude) <getDistance([[Nearest valueForKey:@"pos_x"] floatValue], [[Nearest valueForKey:@"pos_y"] floatValue], self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude) ){
            Nearest = point;
        }
    }
    return Nearest;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.routeButton.layer.cornerRadius = 5;
    self.routeButton.clipsToBounds = YES;
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    NSDictionary *point = [self getNearest];
    NSLog(@"233");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Геопозиция"
                                                                   message:[NSString stringWithFormat:@"Вы случайно не в %@", [point valueForKey:@"title"]] preferredStyle:UIAlertControllerStyleAlert];
    NSLog(@"12322");
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Нет" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* actionYes= [UIAlertAction actionWithTitle:@"Да" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [self.textField setText:[point valueForKey:@"title"]];
        curStore = [[point valueForKey:@"id"] intValue];
    }];
    [alert addAction:actionYes];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:nil];


}

- (IBAction)searchPlace:(UITextField *)sender {
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchPlaceController"];
    // [self addChildViewController:vc];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goToMap:(UIButton *)sender {
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    // [self addChildViewController:vc];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

@implementation SearchPlaceController


- (void)viewDidLoad {
    [super viewDidLoad];
    id data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/getListOfStores/"]];
    NSLog(@"ffff");
    NSArray *stores = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *arr = [[NSArray alloc] initWithArray:stores];
    NSLog(@"%@", [[arr objectAtIndex:0] valueForKey:@"id"]);
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.tableView.dataSource = self;
    self.currentStores = [[NSMutableArray alloc] initWithArray:stores];


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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.returnedData = [self.currentStores objectAtIndex:indexPath.row];
    curStore = [[[self.currentStores objectAtIndex:indexPath.row] valueForKey:@"id"] intValue];
    InitViewController *vc = (InitViewController *) self.presentingViewController.childViewControllers.firstObject;

    [self dismissViewControllerAnimated:YES completion:^void {
        [vc.textField setText:[[self.currentStores objectAtIndex:indexPath.row] valueForKey:@"title"]];
    }];

}

- (void)searchBar:(UISearchBar *_Nonnull)searchBar textDidChange:(NSString *_Nonnull)searchText {
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.currentStores count]; i++) {
        [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];

    }
    [self.currentStores removeAllObjects];
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    int cnt = 0;
    for (NSDictionary *obj in shops) {
        if ([[[obj valueForKey:@"title"] lowercaseString] hasPrefix:[searchText lowercaseString]]) {
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
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getListOfShops/%d/", curStore]]];
    shops = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    self.tabbar.delegate = self;
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getListOfShops/%d/", curStore]]];
    NSDictionary *val = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] objectAtIndex:0];
    UIImage *img = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%d/", [[val valueForKey:@"section_id"] intValue]]]]];
    NSLog(@"%@", [NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%d/", [[val valueForKey:@"section_id"] intValue] ]);
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
    for (NSDictionary *shop in shops) {
        [mpView drawShop:shop];
    }
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setClipsToBounds:YES];
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mpView;
}

- (UIView *)viewForZooming:(UIScrollView *)scrollView {
    return self.mpView;
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

    if (item.tag == 0) {
        NSString *storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchController"];
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
            shopsWay = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil][0]];
            curShop = 0;
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
                for (NSDictionary *obj in way) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.returnedData = [self.currentShops objectAtIndex:indexPath.row];
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    InfoController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InfoController"];
    [self presentViewController:vc animated:YES completion:nil];
    [vc setObject:[self returnedData]];

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

@implementation InfoController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setObject:(NSDictionary *)obj {
    self.shopTitle.title = [obj valueForKey:@"title"];
    NSLog([obj valueForKey:@"title"]);
    self.obj = obj;
}

- (IBAction)selectFrom:(id)sender {
    from = self.obj;
    changedData = true;
    NSLog(@"%f", [self.obj objectForKey:@"pos_x"]);
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)selectTo:(id)sender {
    to = self.obj;
    changedData = true;
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
