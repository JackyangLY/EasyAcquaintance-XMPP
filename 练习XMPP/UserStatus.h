//
//  UserStatus.h
//  练习XMPP
//
//  Created by 洋洋 on 16/8/22.
//  Copyright © 2016年 Jack_yy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserStatus : NSObject
/**用户名*/
@property (nonatomic ,strong)NSString *name;
/**是否在线*/
@property (nonatomic)BOOL isOnline;
@end
