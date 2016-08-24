//
//  LoginVC.m
//  练习XMPP
//
//  Created by 洋洋 on 16/8/22.
//  Copyright © 2016年 Jack_yy. All rights reserved.
//

#import "LoginVC.h"
#import "BCNetConnect.h"
@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark 注册按钮方法
- (IBAction)registerBtnAction:(UIButton *)button
{
    /**将用户输入的用户名和密码保存，连接服务器，并且登录*/
    [self saveUserNameAndPassWord];
    /**服务器进行连接，之后进行注册*/
    [BCNetConnect shareNetConnect].isRegist = YES;
     [[BCNetConnect shareNetConnect]connect];
}
#pragma  mark 登录按钮方法
- (IBAction)LoginBtnAction:(UIButton *)button
{
    /**将用户名输入的用户名和密码保存，连接服务器，并且登录*/
    [self saveUserNameAndPassWord];
    [[BCNetConnect shareNetConnect]connect];

}
#pragma  mark 将用户名输入的用户名和密码保存
-(void)saveUserNameAndPassWord
{
     /**将用户名输入的用户名和密码保存*/
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    /**用户名+域名*/
    NSString *userName = [NSString stringWithFormat:@"%@@yang.local",self.userName.text];
    /**Jid*/
    [userDefaults setObject:userName forKey:@"user"];
    /**密码*/
    [userDefaults setObject:self.passWord.text forKey:@"pwd"];
    /**服务地址*/
    [userDefaults setObject:@"localhost" forKey:@"service"];
    [userDefaults synchronize];

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
