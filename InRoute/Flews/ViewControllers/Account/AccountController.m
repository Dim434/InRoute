//
//  AccountController.m
//  InRoute
//
//  Created by Dmitry on 23.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "AccountController.h"
#import "Manager.h"
#import "Action.h"
#import "StockController.h"
@import QRCodeReaderViewController;

MyManager *sharedManager;

@interface AccountController ()

@end

@implementation AccountController

- (void)viewDidLoad{
    sharedManager = [MyManager sharedManager];
    if(sharedManager.account_session && sharedManager.account_email){
        [self.emailLabel setText:sharedManager.account_email];
    }
    if(sharedManager.curStore == 1){
        // [_actionController registerClass:[Action class] forCellReuseIdentifier:@"act2"];
        [_actionController setHidden:NO];
        [_actionController registerNib:[UINib nibWithNibName:@"Action" bundle:nil]  forCellReuseIdentifier:@"act2"];
        _actionController.delegate = self;
        _actionController.dataSource = self;
        _actionController.tableFooterView = [UIView new];
        
    }else{
        [_actionController setHidden:YES];
        
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(sharedManager.curStore == 1){
        return 2;
    }
    else{
        return 0;
    }}


- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Action *cell= [_actionController dequeueReusableCellWithIdentifier:@"act2" forIndexPath:indexPath];
    if(indexPath.row == 0){
        cell.nameShop.text = @"re:Store";
        [cell.shopIcon setImage:[UIImage imageNamed:@"reStore"]];
    }
    else if(indexPath.row == 1){
        cell.nameShop.text = @"Lego";
        [cell.shopIcon setImage:[UIImage imageNamed:@"lego"]];
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StockController * vc = (StockController *)[sb instantiateViewControllerWithIdentifier:@"StockController"];
    [vc awakeFromNib];
    if(indexPath.row == 0){
        sharedManager.stockImage = [UIImage imageNamed:@"reStore"];
        sharedManager.stockTitle = @"re:Store";
        sharedManager.stockText =@"В re:Store стартуют специальные предложения для учащихся и преподавателей! С 1 августа по 15 ноября сентября действует скидка 10% на ноутбуки Мас. Оставайтесь максимально продуктивными с лучшим гаджетом для эффективной работы и учебы. Подробности получения скидки читайте тут.\n\nА также до конца сентября приобретайте самые популярные гаджеты и аксессуары для работы и учебы с выгодой до 60%\nВыбирайте лучшие устройства для своей эффективности: удобные и функциональные беспроводные мыши, клавиатуры, наушники, зарядные устройства. Или порадуйте себя и своих близких новой акустической системой, портативным проектором и интерактивной обучающей игрушкой.";
        sharedManager.spashImage = [UIImage imageNamed:@"restore-splash"];
        NSLog(@"%@", vc.image.image);
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if(indexPath.row == 1){
        sharedManager.stockImage = [UIImage imageNamed:@"lego"];
        sharedManager.stockTitle = @"LEGO®";
        sharedManager.stockText =@"Сегодня в России открыто более 70-ти сертифицированных магазинов LEGO®. Это официальный партнёр бренда в стране. Здесь поклонники найдут конструкторы LEGO® любимых серий, включая новинки, эксклюзивные и коллекционные наборы.\n\nВ магазинах сети создана неповторимая атмосфера игры и дружбы, где комфортно и детям, и взрослым. Профессиональная команда экспертов в мире кубиков LEGO® увлечённо и со знанием темы расскажет о каждом конструкторе, ответит на вопросы, поможет сделать правильный выбор. Даже простой визит из интереса принесёт вам массу впечатлений, ведь отличительная черта наших магазинов LEGO® – демонстрация некоторых моделей в сборке.\n\nВас порадуют регулярные акции с подарками и скидками, бонусная программа, приятные цены, возможность сделать заказ на сайте, а забрать в магазине, и главное — всегда полный и актуальный ассортимент, какой бывает только в сети сертифицированных магазинов LEGO®!";
        sharedManager.spashImage = [UIImage imageNamed:@"lego-splash"];
        NSLog(@"%@", vc.image.image);
        [self presentViewController:vc animated:YES completion:nil];
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
    
    NSString *userUpdate =[NSString stringWithFormat:@"session=%@&value=%@", sharedManager.account_session, qrValue, nil];
    //create the Method "GET" or "POSTЭ
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
    if(res && [res objectForKey:@"result"]){
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
    sharedManager.account_email = @"";
    sharedManager.account_session = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end

