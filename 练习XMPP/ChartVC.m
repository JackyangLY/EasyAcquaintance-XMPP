//
//  ChartVC.m
//  练习XMPP
//
//  Created by 洋洋 on 16/8/23.
//  Copyright © 2016年 Jack_yy. All rights reserved.
//

#import "ChartVC.h"
#import "Common.h"
#import "MessageCell.h"

@interface ChartVC ()<XMPPStreamDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableContentView;
@property (weak, nonatomic) IBOutlet UITextField *textFileldMessage;
/**所有的当前聊天的消息*/
@property (copy ,nonatomic) NSMutableArray *messageArray;
@end

@implementation ChartVC
-(NSMutableArray *)messageArray
{
    if (!_messageArray)
    {
        _messageArray = [[NSMutableArray alloc]init];
    }
    return _messageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    
    [[BCNetConnect shareNetConnect].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.tableContentView.delegate = self;
    self.tableContentView.dataSource = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    //离开控制器,删除delegate
    [[BCNetConnect shareNetConnect].stream removeDelegate:self];
}

- (IBAction)sendBtnAction:(UIButton *)sender
{
    //    构建一个消息对象
    NSString *body = self.textFileldMessage.text;
    XMPPJID *toJID = [XMPPJID jidWithString:[self.friendName stringByAppendingString:@"@yang.local"]];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:toJID];
    [message addBody:body];
    //    发送消息
    [[BCNetConnect shareNetConnect].stream sendElement:message];
    self.textFileldMessage.text = nil;
    
    //将消息放到数据源中
    Message *mess = [[Message alloc] init];
    mess.from = [BCNetConnect shareNetConnect].stream.myJID.user;
    mess.to = self.friendName;
    mess.body = body;
    mess.isMe = YES;    
    
    [self.messageArray addObject:mess];
    
    [self.tableContentView reloadData];
}
#pragma mark - xmpp stream delegate

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    //只关注当前聊天的消息
    NSString *fromString = message.from.user;
    if (![fromString isEqualToString:self.friendName] ) {
        return;
    }
    //没有内容
    if (message.body  == nil) {
        return;
    }
    //转化为model,保存到数据源
    Message *mess = [[Message alloc] init];
    mess.from = fromString;
    mess.to = sender.myJID.user;
    mess.body = message.body;
    mess.isMe = NO;
    
    [self.messageArray addObject:mess];
    
    [self.tableContentView reloadData];
}

#pragma mark - table View delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = self.messageArray[indexPath.row];
    MessageCell *cell;
    if (message.isMe){
        cell = [tableView dequeueReusableCellWithIdentifier:@"right" forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"left" forIndexPath:indexPath];
    }
    cell.lblname.text = message.from;
    cell.lblboby.text = message.body;
    return cell;
    
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
