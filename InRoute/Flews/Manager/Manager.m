//
//  Manager.m
//  InRoute
//
//  Created by Dmitry on 16.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "Manager.h"

@implementation MyManager

@synthesize shops;
@synthesize pdf;
@synthesize from, to;
@synthesize selected;
@synthesize isFrom;
@synthesize way;
@synthesize shopsWay;
@synthesize curShop;
@synthesize changedData;
@synthesize curStore;
@synthesize stores;
@synthesize account_session ;
@synthesize account_email;
@synthesize storeName;
@synthesize category;
@synthesize stockText;
@synthesize stockImage;
@synthesize stockTitle;
@synthesize spashImage;
#pragma mark Singleton Methods

+ (id)sharedManager {
    static MyManager *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        isFrom = true;
        curShop = 0;
        changedData = false;
        curStore = 1;
        account_session = @"";
        account_email = @"";
        storeName = @"";
    }
    return self;
}

- (void)dealloc {}

@end
