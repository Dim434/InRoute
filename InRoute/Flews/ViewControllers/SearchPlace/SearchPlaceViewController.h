//
//  SearchPlaceViewController.h
//  InRoute
//
//  Created by Dmitry on 16.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ShopViewControllerProtocol <NSObject>

@required
- (void)initMapData;
@end

@interface SearchPlaceController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *currentStores;
@property NSDictionary *returnedData;
@property (assign, nonatomic) id<ShopViewControllerProtocol> delegate;
@end

NS_ASSUME_NONNULL_END
