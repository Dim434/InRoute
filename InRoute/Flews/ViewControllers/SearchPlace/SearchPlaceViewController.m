//
//  SearchPlaceViewController.m
//  InRoute
//
//  Created by Dmitry on 16.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "SearchPlaceViewController.h"
#import "Manager.h"
#import "InitViewController.h"


@interface SearchPlaceController ()

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
    ((MyManager *)[MyManager sharedManager]).stores = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *arr = [[NSArray alloc] initWithArray:((MyManager *)[MyManager sharedManager]).stores];
    NSLog(@"%@", [[arr objectAtIndex:0] valueForKey:@"id"]);
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.tableView.dataSource = self;
    self.currentStores = [[NSMutableArray alloc] initWithArray:((MyManager *)[MyManager sharedManager]).stores];
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
        ((MyManager *)[MyManager sharedManager]).category = @"университеты";
        NSLog(@"U");
        for (int i = 0; i < [self.currentStores count]; i++) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            
        }
        [self.currentStores removeAllObjects];
        int cnt = 0;
        for (NSDictionary *obj in ((MyManager *)[MyManager sharedManager]).stores) {
            if ([[[obj valueForKey:@"category"] lowercaseString] isEqualToString:@"университеты"]) {
                [self.currentStores addObject:obj];
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:cnt inSection:0]];
                cnt++;
            }
        }
    }
    else if([title isEqualToString:@"Shopping Center"]){
        NSLog(@"SC");
        ((MyManager *)[MyManager sharedManager]).category = @"торговые центры";
        for (int i = 0; i < [self.currentStores count]; i++) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            
        }
        [self.currentStores removeAllObjects];
        int cnt = 0;
        for (NSDictionary *obj in ((MyManager *)[MyManager sharedManager]).stores) {
            NSLog(@"%@", [[obj valueForKey:@"category"] lowercaseString]);
            if ([[[obj valueForKey:@"category"] lowercaseString] isEqualToString:@"торговые центры"]) {
                [self.currentStores addObject:obj];
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:cnt inSection:0]];
                cnt++;
            }
        }
        
    }
    else if([title isEqualToString:@"Business Center"]){
        ((MyManager *)[MyManager sharedManager]).category = @"бизнес-центры";
        NSLog(@"BC");
        for (int i = 0; i < [self.currentStores count]; i++) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            
        }
        [self.currentStores removeAllObjects];
        int cnt = 0;
        for (NSDictionary *obj in ((MyManager *)[MyManager sharedManager]).stores) {
            if ([[[obj valueForKey:@"category"] lowercaseString] isEqualToString:@"бизнес-центры"]) {
                [self.currentStores addObject:obj];
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:cnt inSection:0]];
                cnt++;
            }
        }
        
    }
    else if([title isEqualToString:@"Park"]){
        ((MyManager *)[MyManager sharedManager]).category = @"парки";
        NSLog(@"P");
        for (int i = 0; i < [self.currentStores count]; i++) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            
        }
        [self.currentStores removeAllObjects];
        
        int cnt = 0;
        for (NSDictionary *obj in ((MyManager *)[MyManager sharedManager]).stores) {
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
    ((MyManager *)[MyManager sharedManager]).curStore = [[[self.currentStores objectAtIndex:indexPath.row] valueForKey:@"id"] intValue];
    ((MyManager *)[MyManager sharedManager]).storeName = [[self.currentStores objectAtIndex:indexPath.row] valueForKey:@"title"];
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
    for (NSDictionary *obj in ((MyManager *)[MyManager sharedManager]).stores) {
        if ([[[obj valueForKey:@"title"] lowercaseString] hasPrefix:[searchText lowercaseString]]
            && [[[obj valueForKey:@"category"] lowercaseString] containsString: ((MyManager *)[MyManager sharedManager]).category]) {
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
