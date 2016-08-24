//
//  Message.h
//  练习XMPP
//
//  Created by 洋洋 on 16/8/22.
//  Copyright © 2016年 Jack_yy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject
/**消息内容*/
@property (nonatomic ,strong)NSString *body;
@property(nonatomic,strong) NSString *from;
@property(nonatomic,strong) NSString *to;
/**是我发的*/
@property(nonatomic)BOOL isMe;

@end
