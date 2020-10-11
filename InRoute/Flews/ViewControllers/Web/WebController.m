//
//  WebController.m
//  InRoute
//
//  Created by Dmitry on 23.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "WebController.h"
#import "Manager.h"
@import PDFKit;

MyManager *sharedManager;

@interface WebController ()

@end

@implementation WebController

- (void)viewDidLoad {
    sharedManager = [MyManager sharedManager];
    [super viewDidLoad];
    NSLog(@"11");
    // Do any additional setup after loading the view.
    PDFView *ppdf = [[PDFView alloc] initWithFrame:self.view.frame];
    [ppdf setDocument:[[PDFDocument alloc] initWithData:sharedManager.pdf]];
    [self.view addSubview:ppdf];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
