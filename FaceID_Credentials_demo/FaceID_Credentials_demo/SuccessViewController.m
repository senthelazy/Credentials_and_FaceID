//
//  SuccessViewController.m
//  FaceID_Credentials_demo
//
//  Created by sen luo on 2022-11-18.
//

#import "SuccessViewController.h"
#import "Masonry.h"

@interface SuccessViewController ()

@end

@implementation SuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *success=[[UILabel alloc]init];
    success.text=@"Login Successfully";
    success.font=[UIFont systemFontOfSize:24];
    success.textColor=[UIColor blackColor];
    [self.view addSubview:success];
    [success mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(300, 50));
        make.top.equalTo(self.view).offset(500);
        make.left.equalTo(self.view).offset(50);
    }];
    
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
