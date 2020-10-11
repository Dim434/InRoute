//
//  AuthController.h
//  InRoute
//
//  Created by Dmitry on 23.09.2020.
//  Copyright © 2020 g4play. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AuthenticationServices;

NS_ASSUME_NONNULL_BEGIN

@interface AuthController : UIViewController <ASAuthorizationControllerDelegate>
@property (weak, nonatomic) IBOutlet ASAuthorizationAppleIDButton *appleButton;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

NS_ASSUME_NONNULL_END
