//
//  BCNetConnect.m
//  练习XMPP
//
//  Created by 洋洋 on 16/8/22.
//  Copyright © 2016年 Jack_yy. All rights reserved.
//

#import "BCNetConnect.h"
#import "AppDelegate.h"
@interface BCNetConnect()<XMPPStreamDelegate,XMPPRosterDelegate>
@end
@implementation BCNetConnect
+(instancetype)shareNetConnect
{
    static BCNetConnect *connect;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connect = [[BCNetConnect alloc]init];
    });
    return connect;
}
/**连接服务器*/
-(BOOL)connect
{
    /**如果已经存在连接，断开重新连接*/
    if (self.stream.isConnected)
    {
        [self.stream disconnect];
    }
    /**使用用户名，密码，服务器地址连接服务器*/
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:@"user"];
    NSString *passWord = [userDefaults objectForKey:@"pwd"];
    NSString *service = [userDefaults objectForKey:@"service"];
    /**使用服务器地址和用户名，在三个参数都有的时候才能链接*/
    if (!userName||!passWord||!service)
    {
        return NO;
    }
    /**主机地址*/
    self.stream.hostName = service;
    XMPPJID *user = [XMPPJID jidWithString:userName];
    /**服务器的域名*/
    self.stream.myJID = user;
    NSError *error;
    return [self.stream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
}
/**注册账号*/
#pragma  mark 设置状态
-(void)goOnline
{
    /**创建一个状态对象，默认值为上线*/
    XMPPPresence *presence = [XMPPPresence presence];
    [_stream sendElement:presence];
}
#pragma mark -xmpp stream delegate
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    /**打印此方法*/
    NSLog(@"%s\n连接成功",__func__);
    if (!_isRegist)
    {
        /**登录验证*/
        NSString *Strpwd = [[NSUserDefaults standardUserDefaults]objectForKey:@"pwd" ];
        NSError *error;
        [self.stream authenticateWithPassword:Strpwd error:&error];
    }
    else
    {
        /**注册*/
        NSString *Strpwd = [[NSUserDefaults standardUserDefaults]objectForKey:@"pwd" ];
        /**打印此方法*/
        NSLog(@"%s\n注册中。。。",__func__);
        NSError *error;
        [self.stream registerWithPassword:Strpwd error:&error];
    }
}
#pragma  mark 登录成功 XMPP-Delegate
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    /**打印此方法*/
    NSLog(@"%s\n登陆成功",__func__);
    /**设置上线状态*/
    [self goOnline];
    /**登录成功后切换到首页*/
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [appdelegate changeToHome];
    
    /**初始化花名册的存储器和花名册*/
    self.storage = [[XMPPRosterCoreDataStorage alloc]init];
    self.roster = [[XMPPRoster alloc]initWithRosterStorage:self.storage];
    /**绑定stream*/
    [self.roster activate:self.stream];
    /**设置Delegate，已经被stream接收，不会调用Delegate方法*/
    [self.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"%@", error);
}

-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"pwd"];
    NSError *error;
    [self.stream authenticateWithPassword:pwd error:&error];
}

-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"%@", error);
}
#pragma  mark 收到状态改变
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSLog(@"%@", presence);
    /**当前状态是订阅的时候*/
    if ([presence.type isEqualToString:@"subscribe"])
    {
        XMPPJID *from = presence.from;
        /**同意对方的添加，并且添加对方*/
        [self.roster acceptPresenceSubscriptionRequestFrom:from andAddToRoster:YES];
    }
    
}
-(void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error
{
    /**打印此方法*/
    NSLog(@"%s\n%@",__func__,error);
}
-(void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    /**打印此方法*/
    NSLog(@"%s\n%@",__func__,presence);
}
#pragma  mark -get
#pragma XMPP数据流的通道，所有的XML数据流通过该对象收发
-(XMPPStream *)stream
{
    if (!_stream)
    {
        _stream = [[XMPPStream alloc]init];
        /**添加Delegate*/
        [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _stream;
}

@end
