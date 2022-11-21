//
//  ViewController.m
//  FaceID_Credentials_demo
//
//  Created by sen luo on 2022-11-18.
//

#import "ViewController.h"
#import "Masonry.h"//for layout
#import <SVProgressHUD.h>//for progress bar
#import <LocalAuthentication/LocalAuthentication.h>//for face id
#import "SuccessViewController.h"
//#import "MyUserDefaults.h"

@interface ViewController ()<UINavigationControllerDelegate,UITextFieldDelegate>
@property (nonatomic,strong)UITextField *usernameTF;
@property (nonatomic,strong)UITextField *passwordTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer  *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    //delete same server credentials first
//    [self deleteCredentials];
    
    
    //store username and password to keychain
    NSURLCredential *credential=[[NSURLCredential alloc]initWithUser:@"senluo" password:@"12345678" persistence:NSURLCredentialPersistenceNone];
    [self addCredentials:credential server:@"Hello.com"];
    
    self.usernameTF=[[UITextField alloc]init];
    self.usernameTF.font=[UIFont systemFontOfSize:16.0];
    self.usernameTF.textAlignment=NSTextAlignmentNatural;
    self.usernameTF.layer.borderWidth=1;
    self.usernameTF.layer.cornerRadius = 5;
    self.usernameTF.textColor=[UIColor whiteColor];
    self.usernameTF.attributedPlaceholder=[[NSAttributedString alloc]initWithString:@"Enter username for store to Keychain" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    self.usernameTF.layer.borderColor=[UIColor grayColor].CGColor;
    self.usernameTF.keyboardType=UIKeyboardTypeDefault;
    UIView *userPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.usernameTF.leftView = userPaddingView;
    self.usernameTF.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:self.usernameTF];
    [self.usernameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(274, 41));
        make.top.equalTo(self.view).offset(402);
        make.left.equalTo(self.view).offset(36);
        make.right.equalTo(self.view).offset(-36);
    }];
    [self.usernameTF becomeFirstResponder];
    self.usernameTF.returnKeyType=UIReturnKeyDone;
    
    _passwordTF=[[UITextField alloc]init];
    _passwordTF.font=[UIFont systemFontOfSize:16.0];
    _passwordTF.textAlignment=NSTextAlignmentLeft;
    _passwordTF.secureTextEntry=true;
    _passwordTF.layer.cornerRadius = 5;
    _passwordTF.textColor=[UIColor whiteColor];
    _passwordTF.attributedPlaceholder=[[NSAttributedString alloc]initWithString:@"enter password for saving to Keychain" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    _passwordTF.layer.borderWidth=1;
    _passwordTF.layer.borderColor=[UIColor grayColor].CGColor;
    _passwordTF.keyboardType=UIKeyboardTypeDefault;
    _passwordTF.returnKeyType=UIReturnKeyDone;
    UIView *passPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    _passwordTF.leftView = passPaddingView;
    _passwordTF.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_passwordTF];
    [_passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(274, 41));
        make.top.equalTo(self.view).offset(466);
        make.left.equalTo(self.view).offset(36);
        make.right.equalTo(self.view).offset(-36);
    }];
    UIButton *loginBtn=[[UIButton alloc]init];
    [loginBtn setTitle:@"Sign in" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginTap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(335, 50));
        make.top.equalTo(self.view).offset(700);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
    [self verifyFaceID];
}

#pragma - Face ID
-(void)verifyFaceID{
    //Create LAContext
    [SVProgressHUD show];
    LAContext *context = [[LAContext alloc] init];
    //This property is the option to set the pop-up box after biometric authentication fails
    context.localizedFallbackTitle = @"Enter username And password";
    NSDictionary<NSString *,id> *query =@{
        (NSString *)kSecClass:(__bridge id)kSecClassInternetPassword,
        (NSString *)kSecAttrServer:@"Hello.com", //this for distinguish which credentials,change it to your choice
        (NSString *)kSecMatchLimit:(__bridge NSString *)kSecMatchLimitOne,
        (NSString *)kSecReturnAttributes:(id)kCFBooleanTrue,
        (NSString *)kSecUseAuthenticationContext:context,
        (NSString *)kSecReturnData:(id)kCFBooleanTrue,
    };
    //error message
    NSError *error = nil;
    //Judge whether the device supports Face ID or Touch ID
    BOOL isUseFaceOrTouchID = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (isUseFaceOrTouchID) {
        //This is used to verify the TouchID, and a pop-up box will appear
        //The string parameter is the prompt when validation fails
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"verification_failed" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Verification successful");
                    [self readCredentials:query];
                });
                
            } else {
                NSLog(@"%@", error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel: {
                        NSLog(@"The system cancels authorization, such as others APP cut-in");
                        break;
                    }
                    case LAErrorUserCancel: {
                        NSLog(@"User cancels authentication Face ID");
                        [SVProgressHUD dismiss];
                        break;
                    }
                    case LAErrorAuthenticationFailed: {
                        NSLog(@"privilege grant failed");
                        [SVProgressHUD dismiss];
                        break;
                    }
                    case LAErrorPasscodeNotSet: {
                        NSLog(@"The system does not set a password");
                        [SVProgressHUD dismiss];
                        break;
                    }
                    case LAErrorBiometryNotAvailable: {
                        NSLog(@"equipment Face ID Not available, e.g. not open");
                        [SVProgressHUD dismiss];
                        break;
                    }
                    case LAErrorBiometryNotEnrolled: {
                        NSLog(@"equipment Face ID Not available, not entered by user");
                        [SVProgressHUD dismiss];
                        break;
                    }
                    case LAErrorUserFallback: {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"User input password");
                            [SVProgressHUD dismiss];
                        }];
                        break;
                    }
                    default: {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"In other cases, switch the main thread processing");
                            [SVProgressHUD dismiss];
                        }];
                        break;
                    }
                }
            }
        }];
        
    } else {
        NSLog(@"I won't support Face ID or Touch ID");
        switch (error.code) {
            case LAErrorBiometryNotEnrolled: {
                NSLog(@"Face ID unregistered");
                [SVProgressHUD dismiss];
                break;
            }
            case LAErrorPasscodeNotSet: {
                NSLog(@"No password set");
                [SVProgressHUD dismiss];
                break;
            }
            default: {
                NSLog(@"Face ID Not available");
                [SVProgressHUD dismiss];
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
}


//take username and password from keychain
-(void)readCredentials:(NSDictionary *)query{
    CFTypeRef result = NULL;
    OSStatus status =SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if(status==errSecSuccess){
        NSDictionary *resultDict=(__bridge NSDictionary *)result;
        NSData *passwordValue=[resultDict objectForKey:(__bridge id)(kSecValueData)];
        NSString *password = [NSString stringWithUTF8String:[passwordValue bytes]]?[NSString stringWithUTF8String:[passwordValue bytes]]:@"";
        
        NSString *account=[resultDict objectForKey:(__bridge id)(kSecAttrAccount)];
        _passwordTF.text=password;
        _usernameTF.text=account;
        [self loginWhenMatch:_usernameTF.text password:_passwordTF.text];
    }
    
    if (status == errSecItemNotFound) {
        NSLog(@" No items for the class.");
        
    }
    if (status != errSecSuccess) {
        NSLog(@" Failed to read from keychain");
        
    }
    if (result == NULL) {
        NSLog(@" No data the class");
        
    }
    if (result != NULL) CFRelease(result);
}

#pragma - keychain operations
// store credentials in keychain for Face ID or Touch ID
- (void)addCredentials:(NSURLCredential *)credentials server:(NSString *)server
{
    NSString *account = credentials.user;
    NSString *password = credentials.password;
    if (!account || !password || !server) {
        @throw [[NSException alloc] initWithName:@"AddCredentialsError" reason:@"params is nil" userInfo:nil];
    }
    SecAccessControlRef access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kSecAccessControlUserPresence, nil);
    LAContext *context = [[LAContext alloc] init];
//    context.touchIDAuthenticationAllowableReuseDuration = 10;
    
    NSDictionary<NSString *, id> *query = @{
        (NSString *)kSecClass: (__bridge id)kSecClassInternetPassword,
        (NSString *)kSecAttrServer: server,
        (NSString *)kSecAttrAccount: account,
        (NSString *)kSecAttrAccessControl: (__bridge id)access,
        (NSString *)kSecUseAuthenticationContext: context,
        (NSString *)kSecValueData: [password dataUsingEncoding:NSUTF8StringEncoding],
    };
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    if(status==errSecSuccess){
//        [MyUserDefaults setBool:YES forKey:NOT_FIRST_TIME_LOGIN]//for alert
    }
    if (status != errSecSuccess && [@(status) intValue]!=-25299) {//If report errSecDuplicateItem -25299（means already has credentials in keychain）
        @throw [[NSException alloc] initWithName:@"AddCredentialsError" reason:@"Sec Item Add Failed" userInfo:@{@"status":@(status)}];
    }

}

-(void)loginWhenMatch:(NSString *)usernameStr password:(NSString *)passwordStr{
//    if(usernameStr && usernameStr.length>0 && passwordStr && passwordStr.length>0){
    if([usernameStr isEqualToString:@"senluo"] && [passwordStr isEqualToString:@"12345678"]){
//        SuccessViewController *vc=[[SuccessViewController alloc]init];
//        [self.navigationController pushViewController:vc animated:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reminder" message:@"Successful" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];
        [SVProgressHUD dismiss];
    
    }
}

//delete crendentials for particular server
-(void)deleteCredentials{
    NSDictionary<NSString *,id> *query =@{
        (NSString *)kSecClass:(__bridge id)kSecClassInternetPassword,
        (NSString *)kSecAttrServer:@"Hello.com",
    };
    OSStatus status =SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess ) {
        @throw [[NSException alloc] initWithName:@"DeleteCredentialsError" reason:@"Sec Item Delete Failed" userInfo:@{@"status":@(status)}];
    }
}

- (void)keyboardHide{
[self.view endEditing:YES];
}

-(void)loginTap{
    NSURLCredential *credential;
    credential=[[NSURLCredential alloc]initWithUser:_usernameTF.text password:_passwordTF.text persistence:NSURLCredentialPersistenceNone];
    [self addCredentials:credential server:@"Hello.com"];
    [self loginWhenMatch:_usernameTF.text password:_passwordTF.text];
    
    
}

-(void)textFieldDone{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==_usernameTF){
        [_passwordTF becomeFirstResponder];
    }else if(textField==_passwordTF){
        [_passwordTF resignFirstResponder];
        [self loginTap];
    }
    return YES;
}
@end
