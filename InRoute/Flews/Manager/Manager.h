//
//  Manager.h
//  InRoute
//
//  Created by Dmitry on 16.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface MyManager : NSObject {
    NSArray *shops;
    NSData *pdf;
    NSDictionary *from, *to;
    NSDictionary *selected;
    bool isFrom;
    NSMutableArray *way;
    NSMutableArray *shopsWay;
    int curShop;
    bool changedData;
    int curStore;
    NSArray* stores;
    NSString * account_session;
    NSString * account_email;
    NSString * storeName;
    NSString * category;
    NSString * stockTitle;
    NSString * stockText;
    UIImage * stockImage;
    UIImage * spashImage;
    
}

@property (nonatomic, retain)NSArray *shops;
@property (nonatomic, retain) NSData *pdf;
@property (nonatomic, retain)NSDictionary *from, *to;
@property (nonatomic, retain) NSDictionary *selected;
@property (nonatomic) bool isFrom;
@property (nonatomic, retain) NSMutableArray *way;
@property (nonatomic, retain) NSMutableArray *shopsWay;
@property (nonatomic) int curShop;
@property (nonatomic) bool changedData;
@property (nonatomic) int curStore;
@property (nonatomic, retain) NSArray* stores;
@property (nonatomic, retain) NSString * account_session;
@property (nonatomic, retain) NSString * account_email;
@property (nonatomic, retain) NSString * storeName;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * stockTitle;
@property (nonatomic, retain) NSString * stockText;
@property (nonatomic, retain) UIImage * stockImage;
@property (nonatomic, retain) UIImage * spashImage;


+ (id)sharedManager;

@end

NS_ASSUME_NONNULL_END

