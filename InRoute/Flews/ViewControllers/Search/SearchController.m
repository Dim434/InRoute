//
//  SearchController.m
//  InRoute
//
//  Created by Dmitry on 23.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "SearchController.h"
@import UIKit;
#import "Manager.h"

@interface SearchController ()
- (void)initData;
@end

MyManager *sharedManager;

@implementation SearchController

- (void)viewDidLoad {
    sharedManager = [MyManager sharedManager];
    [super viewDidLoad];
    NSArray *arr = [[NSArray alloc] initWithArray:sharedManager.shops];
    NSLog(@"%@", [[arr objectAtIndex:0] valueForKey:@"id"]);
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.tableView.dataSource = self;
    self.currentShops = [[NSMutableArray alloc] initWithArray:sharedManager.shops];
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
        [self.delegate selectedData:sharedManager.selected];
    }
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.returnedData = [self.currentShops objectAtIndex:indexPath.row];
    sharedManager.selected = self.returnedData;
    [self OnDoneBlock];
    sharedManager.changedData = true;
}

- (void)searchBar:(UISearchBar *_Nonnull)searchBar textDidChange:(NSString *_Nonnull)searchText {
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.currentShops count]; i++) {
        [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
    }
    [self.currentShops removeAllObjects];
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    int cnt = 0;
    for (NSDictionary *obj in sharedManager.shops) {
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
