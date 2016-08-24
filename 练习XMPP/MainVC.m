//
//  ViewController.m
//  练习XMPP
//
//  Created by 洋洋 on 16/8/22.
//  Copyright © 2016年 Jack_yy. All rights reserved.
//

#import "MainVC.h"
#import "Common.h"
@interface MainVC ()<UITableViewDelegate,UITableViewDataSource,XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableContentView;
@property (nonatomic ,strong)NSMutableArray *friends;
@property (nonatomic ,strong)NSMutableArray *messages;

@end

@implementation MainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBasicSetting];
}
#pragma mark 加载默认设置
-(void)loadBasicSetting
{
    /**初始化*/
    self.friends = [NSMutableArray array];
    self.messages = [NSMutableArray array];
    /**接收streamdelegate*/
    [[BCNetConnect shareNetConnect].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.tableContentView.delegate = self;
    self.tableContentView.dataSource = self;
    
}

#pragma mark - xmpp stream delegate
//好友上线或者下线的delegate
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    /**打印此方法*/
    NSLog(@"%s\n%@",__func__,presence);
    /**当前用户的名字*/
    NSString *currentName = sender.myJID.user;
    /**发送人的名字*/
    NSString *fromString = presence.from.user;
    /**接收人*/
    NSString *toString = presence.to.user;
    /**消息的类型*/
    NSString *PType = presence.type;
    /**当收到别人发送给我的消息的时候*/
    if (![currentName isEqualToString:fromString]) {
        UserStatus *status = [[UserStatus alloc]init];
        status.name = fromString;
        /**available是上线的时候，消息的类型*/
        status.isOnline = [PType isEqualToString:@"available"]?YES:NO;
        NSInteger count = self.friends.count;
        for (NSInteger index = 0; index < count; index++)
        {
            UserStatus *statu = self.friends[index];
            /**如果已经存在该用户，更新用户状态*/
            if ([statu.name isEqualToString:status.name]) {
                [self.friends removeObject:statu];
                [self.friends insertObject:status atIndex:index];
            }
        }
        /**当没有在之前的循环中被添加，那么是新用户，追加到后面*/
        if (![self.friends containsObject:status]) {
            [self.friends addObject:status];
        }
        [self.tableContentView reloadData];
    }
 
}
#pragma  mark 收到消息的Delegate方法
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if (message.body == nil)
    {
        return;
    }
    /**将收到的消息，转化为模型对象*/
    Message *messageModel =[[Message alloc]init];
    messageModel.from = message.from.user;
    messageModel.to = message.to.user;
    if ([messageModel.from isEqualToString:sender.myJID.user])
    {
        messageModel.isMe = YES;
    }
    else
    {
        messageModel.isMe = NO;
    }
    messageModel.body = message.body;
    [self.messages addObject:messageModel];
    [self.tableContentView reloadData];
}

#pragma  mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendcell" forIndexPath:indexPath];
    UserStatus *friend = self.friends[indexPath.row];
    /**显示用户名和状态*/
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",friend.name,friend.isOnline ?@"在线":@"离线"];
    /**遍历消息数组，找到所有当前好友发送的未读消息，以及最后一条消息*/
    NSMutableArray *friendMessages = [NSMutableArray array];
    NSInteger count = self.messages.count;
    for (NSInteger index = 0; index < count; index++)
    {
        Message *message = self.messages[index];
        /**判断如果用户一致*/
        if ([friend.name isEqualToString:message.from])
        {
            [friendMessages addObject:message];
        }
    }
    NSString *text = [NSString stringWithFormat:@"%@ %ld",[[friendMessages lastObject] body],friendMessages.count];
    cell.detailTextLabel.text = text;
    return cell;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /**清理当前好友的未读消息
     *将好友传递给下一个控制器
     *找到好友
     */
    if ([segue.identifier isEqualToString:@"chart"])
    {
        NSIndexPath *indexPath = [self.tableContentView indexPathForCell:sender];
        UserStatus *user = self.friends[indexPath.row];
        /**清理未读消息*/
        NSMutableArray *messages = [self.messages mutableCopy];
        NSInteger count = self.messages.count;
        for (NSInteger index = 0; index < count; index++)
        {
            Message *mess = self.messages[index];
            if ([mess.from isEqualToString:user.name])
            {
                [messages removeObject:mess];
             }
            
        }
        self.messages = messages;
        [self.tableContentView reloadData];
        
        /**将聊天对象，传递给下一个控制器*/
        UIViewController *VC= segue.destinationViewController;
        [VC setValue:user.name forKey:@"friendName"];
    }
}
@end
