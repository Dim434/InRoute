//
//  SearchController.h
//  InRoute
//
//  Created by Dmitry on 23.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchControllerProtocol <NSObject>
@required
- (void)selectedData:(NSDictionary *_Nonnull)selected;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SearchController :  UIViewController <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSDictionary *returnedData;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *currentShops;
@property (weak, nonatomic) id<SearchControllerProtocol> delegate;
@end
NS_ASSUME_NONNULL_END
