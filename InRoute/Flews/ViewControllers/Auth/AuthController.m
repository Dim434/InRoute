//
//  AuthController.m
//  InRoute
//
//  Created by Dmitry on 23.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import "AuthController.h"
#import "Manager.h"
@interface AuthController ()

@end

MyManager *sharedManager;

@implementation AuthController

- (void)viewDidLoad{
    sharedManager = [MyManager sharedManager];
    NSLog(@"loaded");
    [super viewDidLoad];
    [self.appleButton initWithAuthorizationButtonType:ASAuthorizationAppleIDButtonTypeDefault authorizationButtonStyle:ASAuthorizationAppleIDButtonStyleBlack];
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization{
    
    if([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]){
        ASAuthorizationAppleIDCredential *creds = authorization.credential;
        NSLog(@"%@", creds.user);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/appleSign/"]];
        
        NSString *userUpdate =[NSString stringWithFormat:@"userID=%@", creds.user, nil];
        
        //create the Method "GET" or "POST"
        
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
        if(res && [res objectForKey:@"key"])
        {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:[res objectForKey:@"key"] forKey:@"session_inroute"];
            [prefs setObject:creds.fullName.givenName forKey:@"email_inroute"];
            sharedManager.account_session = [res objectForKey:@"key"];
            sharedManager.account_email = creds.fullName.givenName;
            NSLog(@"%@", sharedManager.account_email);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            NSLog(@"Error");
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Ошибка авторизации"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else{
        NSLog(@"we fucked up");
    }
}
- (IBAction)touchDown:(id)sender {
    __auto_type req = [[ASAuthorizationAppleIDProvider new] createRequest];
    req.requestedScopes = @[ASAuthorizationScopeEmail, ASAuthorizationScopeFullName];
    __auto_type controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[req]];
    controller.delegate = self;
    controller.presentationContextProvider = self;
    [controller performRequests];
}
- (ASPresentationAnchor)presentationAnchor:(ASPresentationAnchor *)controller{
    return (UIWindow *)self.view.window;
}
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
- (IBAction)loginButton:(id)sender {
    [self.view endEditing:YES];
    __block bool dismisss = false;
    NSString * email = self.emailField.text;
    NSString * password = self.passwordField.text;
    if(password.length < 8){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                       message:@"В пароле меньше 8 символов"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if(![self validateEmailWithString:email]){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                       message:@"Не правильно введен email"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/login/"]];
    
    NSString *userUpdate =[NSString stringWithFormat:@"email=%@&password=%@",email,password, nil];
    
    //create the Method "GET" or "POST"
    
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
    if(res && [res objectForKey:@"key"])
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[res objectForKey:@"key"] forKey:@"session_inroute"];
        [prefs setObject:email forKey:@"email_inroute"];
        sharedManager.account_session = [res objectForKey:@"key"];
        sharedManager.account_email = email;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSLog(@"Error");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Неправильный логин/пароль"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    if(dismisss)
        [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)registerButton:(id)sender {
    [self.view endEditing:YES];
    __block bool dismisss = false;
    NSString * email = self.emailField.text;
    NSString * password = self.passwordField.text;
    if(password.length < 8){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                       message:@"В пароле меньше 8 символов"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if(![self validateEmailWithString:email]){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                       message:@"Не правильно введен email"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://g4play.ru/api/v0.2/register/"]];
    
    NSString *userUpdate =[NSString stringWithFormat:@"email=%@&password=%@",email,password, nil];
    
    //create the Method "GET" or "POST"
    
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
    if(res && [res objectForKey:@"key"])
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[res objectForKey:@"key"] forKey:@"session_inroute"];
        [prefs setObject:email forKey:@"email_inroute"];
        sharedManager.account_session = [res objectForKey:@"key"];
        sharedManager.account_email = email;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSLog(@"Error");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Email уже занят"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    if(dismisss)
        [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
