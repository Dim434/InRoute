//
//  ViewController.m
//  InRoute
//
//  Created by Admin on 24/03/2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "MainViewController.h"
#import "MapView.h"
#import "QRCodeReaderViewController.h"
#import "UserNotifications/UserNotifications.h"
#import "SearchPlaceViewController.h"
#import "Manager.h"
#import "SearchController.h"
#import "AuthController.h"
#import "AccountController.h"
#import "WebController.h"
@import WebKit;
@import PDFKit;



MyManager *sharedManager;



@interface MainViewController ()
- (void)initMapData;
@end



@interface MyScrollView ()

- (CGRect)zoomRect:(CGFloat)scale center:(CGPoint)center;
- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer;

@end

@implementation MyScrollView

- (CGRect)zoomRect:(CGFloat)scale center:(CGPoint)center{
    __auto_type zoomRect = CGRectZero;
    zoomRect.size.height = _mpView.frame.size.height / scale;
    zoomRect.size.width = _mpView.frame.size.width / scale;
    __auto_type newCenter = [self convertPoint:center toView:_mpView];
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0) + 100;
    return zoomRect;
    
}
- (void)setMpView:(MapView *)mpView{
    _mpView = mpView;
}
- (void)setScaleF:(double)scaleF{
    _scaleF = scaleF;
}
- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if(self.zoomScale == self->_scaleF){
        __auto_type tapPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
        __auto_type rect = [self zoomRect:4.0 center:tapPoint];
        [self zoomToRect:rect animated:YES];
    }
    else{
        self.zoomScale = self->_scaleF;
        
    }
}

@synthesize visibleSize;

@end



@implementation MainViewController
- (void)initData {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    sharedManager.account_session = [prefs valueForKey:@"session_inroute"];
    sharedManager.account_email = [prefs valueForKey:@"email_inroute"];
    sharedManager.pdf = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSchedule/%d/", sharedManager.curStore]]];
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getListOfShops/%d/", sharedManager.curStore]]];
    sharedManager.shops = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSURLRequest *reqq = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSchedule/%d/", sharedManager.curStore]]];
    if (sharedManager.curStore == 4){
        [self.ppdf setHidden:NO];
    }else{
        [self.ppdf setHidden:YES];
    }
    __auto_type task = [[NSURLSession sharedSession] dataTaskWithRequest:reqq completionHandler:^(NSData *data, NSURLResponse *  response, NSError *  error) {
        NSHTTPURLResponse *responsee = (NSHTTPURLResponse *) response;
        if(responsee.statusCode !=200){
            [self->_ppdf setHidden:YES];
        }
        else{
            [self->_ppdf setHidden:FALSE];
        }
        
    }];
    [task resume];
    
}

- (IBAction)displayPDF:(id)sender{
    [self performSegueWithIdentifier:@"next" sender:nil];
    
}

- (void)initMapData {
    [self initData];
    [self.fromField setText:@""];
    [self.toField setText:@""];
    sharedManager.from = nil;
    sharedManager.to = nil;
    [self.storeLabel setTitle: sharedManager.storeName forState:UIControlStateNormal];
    /*    self.stepButton.layer.cornerRadius = 38 / 2.0f;
     [self.stepButton.layer setShadowOffset:CGSizeMake(5, 5)];
     [self.stepButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
     [self.stepButton.layer setShadowOpacity:0.5];*/
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getListOfShops/%d/", sharedManager.curStore]]];
    NSDictionary *val = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] objectAtIndex:0];
    UIImage *img = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%d/", [[val valueForKey:@"section_id"] intValue]]]]];
    /*   NSLog(@"%@", [NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%d/", [[val valueForKey:@"section_id"] intValue] ]);*/
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
    [mpView drawImage:img];
    _mpView.frame = _mpView.image.frame;
    [_scrollView setScaleF:scaleF];
    [_scrollView setMpView:mpView];
    for (NSDictionary *shop in sharedManager.shops) {
        if ([[shop valueForKey:@"section_id"] intValue] == [[val valueForKey:@"section_id"] intValue] ) {
            [self.mpView drawShop:shop];
        }
    }
    self.scaleF = scaleF;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setClipsToBounds:YES];
    self.scrollView.minimumZoomScale = scaleF;
    self.scrollView.maximumZoomScale = 4.0;
    self.scrollView.zoomScale = scaleF;
    self.scrollView.delegate = self;
    __auto_type tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.scrollView action:@selector(handleDoubleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [_scrollView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidLoad {
    sharedManager = [MyManager sharedManager];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initMapData];
    self.stepLabel.layer.cornerRadius = 20;
    
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
    if (!sharedManager.account_session)
        sharedManager.account_session = @"";
    if ([sharedManager.account_session isEqualToString:@""]){
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
    if (sharedManager.from != nil && sharedManager.to != nil) {
        if (sharedManager.way == nil || sharedManager.changedData) {
            sharedManager.changedData = false;
            [self.mpView clearShops];
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getRoute/%@/%@/", [sharedManager.from valueForKey:@"id"], [sharedManager.to valueForKey:@"id"]]]];
            sharedManager.way = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil][1]];
            if([sharedManager.way count] == 0){
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                               message:@"Извините, путь между этими магазинами еще не проложен, наши сотрудники делают все возможное, чтобы исправить эту оплошность"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                sharedManager.way = nil;
                return;
            }
            sharedManager.shopsWay = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil][0]];
            sharedManager.curShop = 0;
            UIImage *img = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%@/", [[sharedManager.shopsWay objectAtIndex:sharedManager.curShop] valueForKey:@"section_id"]]]]];
            MapView *mpView = [[MapView alloc] init];
            self.mpView = mpView;
            self.mpView.frame = CGRectMake(0, 0, MAX(self.scrollView.frame.size.width, img.size.width), MAX(self.scrollView.frame.size.height, img.size.height));
            for (UIView *view in self.scrollView.subviews) {
                [view removeFromSuperview];
            }
            self.mpView.frame = CGRectMake(0, 0, MAX(self.scrollView.frame.size.width, img.size.width), MAX(self.scrollView.frame.size.height, img.size.height));
            
            [self.scrollView addSubview:mpView];
            double scaleF = self.scrollView.frame.size.width / img.size.width;
            
            NSLog(@"Float: %f, %f, %f", scaleF, img.size.width, img.size.height);
            
            
            
            [mpView drawImage:img];
            _mpView.frame = _mpView.image.frame;
            [_scrollView setScaleF:scaleF];
            [_scrollView setMpView:mpView];
            self.scaleF = scaleF;
            self.scrollView.showsVerticalScrollIndicator = NO;
            self.scrollView.showsHorizontalScrollIndicator = NO;
            [self.scrollView setScrollEnabled:YES];
            [self.scrollView setClipsToBounds:YES];
            self.scrollView.minimumZoomScale = scaleF;
            self.scrollView.maximumZoomScale = 4.0;
            self.scrollView.zoomScale = scaleF;
            self.scrollView.delegate = self;
            for (NSDictionary* obj in sharedManager.shopsWay) {
                if ([obj valueForKey:@"section_id"] == [[sharedManager.shopsWay objectAtIndex:sharedManager.curShop] valueForKey:@"section_id"]) {
                    NSLog(@"%d", [obj valueForKey:@"section_id"]);
                    [self.mpView drawShop:obj];
                    [self.mpView drawLine];
                }
            }
            NSDictionary *final = @{@"desc": @"Путь завершен!"};
            [sharedManager.way addObject:final];
            NSLog(@"fuck");
            [self.stepLabel setText:[[sharedManager.way objectAtIndex:0] valueForKey:@"desc"]];
            [sharedManager.way removeObjectAtIndex:0];
        } else {
            sharedManager.curShop++;
            if ([[sharedManager.shopsWay objectAtIndex:sharedManager.curShop] valueForKey:@"section_id"] != [[sharedManager.shopsWay objectAtIndex:(sharedManager.curShop - 1)] valueForKey:@"section_id"]) {
                UIImage *img = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://g4play.ru/api/v0.2/getSectionImage/%@/", [[sharedManager.shopsWay objectAtIndex:sharedManager.curShop] valueForKey:@"section_id"]]]]];
                MapView *mpView = [[MapView alloc] init];
                [_mpView clearImage];
                [_mpView clearShops];
                [_mpView removeFromSuperview];
                self.mpView = mpView;
                self.mpView.frame = CGRectMake(0, 0, MAX(self.scrollView.frame.size.width, img.size.width), MAX(self.scrollView.frame.size.height, img.size.height));
                
                [self.scrollView addSubview:mpView];
                double scaleF = self.scrollView.frame.size.width / img.size.width;
                
                NSLog(@"Float: %f, %f, %f", scaleF, img.size.width, img.size.height);
                
                
                
                [mpView drawImage:img];
                _mpView.frame = _mpView.image.frame;
                [_scrollView setScaleF:scaleF];
                [_scrollView setMpView:mpView];
                self.scaleF = scaleF;
                self.scrollView.showsVerticalScrollIndicator = NO;
                self.scrollView.showsHorizontalScrollIndicator = NO;
                [self.scrollView setScrollEnabled:YES];
                [self.scrollView setClipsToBounds:YES];
                self.scrollView.minimumZoomScale = scaleF;
                self.scrollView.maximumZoomScale = 4.0;
                self.scrollView.zoomScale = scaleF;
                self.scrollView.delegate = self;
                NSLog(@"CUR: %d",[[[sharedManager.shopsWay objectAtIndex:sharedManager.curShop] valueForKey:@"section_id"] intValue]);
                for (NSDictionary *obj in sharedManager.shopsWay) {
                    NSLog(@"Smth %d", [[obj valueForKey:@"section_id"] intValue] );
                    if ([obj valueForKey:@"section_id"] == [[sharedManager.shopsWay objectAtIndex:sharedManager.curShop] valueForKey:@"section_id"]) {
                        [self.mpView drawShop:obj];
                        [self.mpView drawLine];
                    }
                }
            }
            [self.stepLabel setText:[[sharedManager.way objectAtIndex:0] valueForKey:@"desc"]];
            [sharedManager.way removeObjectAtIndex:0];
            if ([sharedManager.way count] == 0)
                sharedManager.way = nil;
        }
    }
}
- (IBAction)fromSelect:(id)sender {
    sharedManager.isFrom=true;
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    SearchController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchController"];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (IBAction)toFieldSelect:(id)sender {
    sharedManager.isFrom = false;
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    SearchController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchController"];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (void)selectedData:(NSDictionary*)selected{
    
    if(sharedManager.isFrom == true){
        sharedManager.from = selected;
        NSLog(@"%@",[selected valueForKey:@"title"]);
        [self.fromField setText:[selected valueForKey:@"title"]  ];
        
    }
    else{
        sharedManager.to = selected;
        [self.toField setText:[selected valueForKey:@"title"]];
    }
}

@end

