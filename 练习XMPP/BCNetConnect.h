//
//  BCNetConnect.h
//  练习XMPP
//
//  Created by 洋洋 on 16/8/22.
//  Copyright © 2016年 Jack_yy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "XMPPRosterCoreDataStorage.h"
@interface BCNetConnect : NSObject
/**客户端*/
@property (nonatomic , strong)XMPPStream *stream;
/**当前连接后的操作*/
@property (nonatomic)BOOL isRegist;
/**花名册的存储器*/
@property (nonatomic ,strong)XMPPRosterCoreDataStorage *storage;
/**花名册，管理好友*/
@property (nonatomic ,strong)XMPPRoster *roster;
/**获取单例对象*/
+(instancetype)shareNetConnect;
/**连接服务器*/
-(BOOL)connect;
@end
