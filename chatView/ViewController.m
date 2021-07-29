//
//  ViewController.m
//  chatView
//
//  Created by tushikun on 2020/7/29.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import "ViewController.h"
#import "VKNeZhaRecordButton.h"
#import "VKNeZhaChatCell.h"
#import "VKTestModel.h"
//
//
#import <AVFoundation/AVFoundation.h>

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

//  master 7 - 28 1
//  merge测试 master

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,VKNeZhaRecordButtonDelegate>
@property (nonatomic, strong) UILabel  *noDataLabel;
@property (nonatomic, strong) UITableView  *tableView;

@property (nonatomic, strong) VKTestModel *kModel;
@property (nonatomic, strong) VKNeZhaChatCell *cell;

@property (nonatomic, strong) AVPlayer  *player;

@end

@implementation ViewController
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 88, Screen_Width, Screen_Height - 101 - 88) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.showsHorizontalScrollIndicator = NO;
        [_tableView registerClass:[VKNeZhaChatCell class] forCellReuseIdentifier:@"VKNeZhaChatCell"];
    }
    return _tableView;
}

- (UILabel *)noDataLabel {
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        CGFloat labelWidth = 120;
        CGFloat labelHeight = 20;
        _noDataLabel.frame = CGRectMake((Screen_Width - labelWidth)/2, (Screen_Height - labelHeight)/2, labelWidth, labelHeight);
        
        _noDataLabel.text = @"老师还未点评";
        _noDataLabel.font = [UIFont fontWithName:@"PingFang-SC" size: 14];
        _noDataLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.alpha = 0.2;
    }
    return _noDataLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpBottomBtnView];
    
    //显示无数据label
//    [self setUpNoDataLabel];
    //假数据
    [self setUpModel];
    //设置tableView
    [self setUpBaseView];
    
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"https://img.vipkidstatic.com/cls/nezha/img/a5c446cc-79be-4aaf-a467-aa42cb0cd089.mp3"]];
    self.player = [[AVPlayer alloc] initWithPlayerItem:item];
    NSLog(@"status ======= %ld",(long)self.player.currentItem.status);
    [self.player play];
    
}

- (void)setUpBaseView {
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.tableView];
    
}

- (void)setUpNoDataLabel {
    [self.view addSubview:self.noDataLabel];
}

- (void)setUpBottomBtnView {
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_Height - 100, Screen_Width, 100)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    bottomView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    bottomView.layer.shadowOpacity = 1;
    bottomView.layer.shadowOffset = CGSizeMake(0, -0.5);
    bottomView.layer.shadowRadius = 0;
    
    VKNeZhaRecordButton *speakBtn = [[VKNeZhaRecordButton alloc] initWithFrame:CGRectMake(29, 10, Screen_Width - 29*2, 45)];
    speakBtn.delegate = self;
    [bottomView addSubview:speakBtn];
}

#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.kModel.timeArray.count;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    VKTestTimeModel *time = self.kModel.timeArray[section];
    return time.messageArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"VKNeZhaChatCell";
    VKNeZhaChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[VKNeZhaChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //更新数据
    VKTestTimeModel *time = self.kModel.timeArray[indexPath.section];
    VKTestMessageModel *message = time.messageArray[indexPath.row];
    [cell reloadDataWithModel:message];
    //点击播放声音
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.messageBtnClick = ^{
        if ([weakSelf.cell isAnimation] && weakSelf.cell != cell) {
            [weakSelf.cell stopAnimation];
        }
        weakSelf.cell = weakCell;
        //if(正在播放) 停止播放
        //开始播放 请求接口 刷新数据源
        VKTestTimeModel *timeModel = weakSelf.kModel.timeArray[indexPath.section];
        VKTestMessageModel *messageModel = timeModel.messageArray[indexPath.row];
        messageModel.isRead = true;
        [timeModel.messageArray replaceObjectAtIndex:indexPath.row withObject:messageModel];
        
        //影响动画效果
        [weakSelf.tableView reloadData];
    };
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = @"06-08 08:23";
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.alpha = 0.3;
    timeLabel.font = [UIFont systemFontOfSize:12.5];
    
    return timeLabel;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //Footer高度设置为0
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //   return 0.001f;
    return 45.f;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}



#pragma mark 假数据
- (void)setUpModel {
    self.kModel = [[VKTestModel alloc] init];
    self.kModel.timeArray = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        VKTestTimeModel *timeModel = [[VKTestTimeModel alloc] init];
        timeModel.messageArray = [NSMutableArray array];
        if (i == 0) {
            timeModel.messageTime = @"06-08 09：22";
            for (int j = 0; j < 3; j++) {
                switch (j) {
                    case 0: {
                        VKTestMessageModel *messageModel = [[VKTestMessageModel alloc] init];
                        messageModel.nameStr = @"辅导老师";
                        messageModel.avatarUrl = @"nz_teacher_avatar";
                        messageModel.messageType = 0;
                        messageModel.messageLength = 58;
                        messageModel.isRead = false;
                        [timeModel.messageArray addObject:messageModel];
                    }
                        break;
                    case 1: {
                        VKTestMessageModel *messageModel = [[VKTestMessageModel alloc] init];
                        messageModel.nameStr = @"Linda";
                        messageModel.avatarUrl = @"nz-me-avater";
                        messageModel.messageType = 1;
                        messageModel.messageLength = 45;
                        messageModel.isRead = true;
                        [timeModel.messageArray addObject:messageModel];
                    }
                        break;
                    case 2: {
                        VKTestMessageModel *messageModel = [[VKTestMessageModel alloc] init];
                        messageModel.nameStr = @"辅导老师";
                        messageModel.avatarUrl = @"nz_teacher_avatar";
                        messageModel.messageType = 0;
                        messageModel.messageLength = 35;
                        messageModel.isRead = false;
                        [timeModel.messageArray addObject:messageModel];
                    }
                        break;
                    default:
                        break;
                }
            }
        }else if (i == 1) {
            timeModel.messageTime = @"07-08 02：22";
            for (int i = 0; i < 3; i++) {
                switch (i) {
                    case 0: {
                        VKTestMessageModel *messageModel = [[VKTestMessageModel alloc] init];
                        messageModel.nameStr = @"辅导老师";
                        messageModel.avatarUrl = @"nz_teacher_avatar";
                        messageModel.messageType = 0;
                        messageModel.messageLength = 55;
                        messageModel.isRead = true;
                        [timeModel.messageArray addObject:messageModel];
                    }
                        break;
                    case 1: {
                        VKTestMessageModel *messageModel = [[VKTestMessageModel alloc] init];
                        messageModel.nameStr = @"Linda";
                        messageModel.avatarUrl = @"nz-me-avater";
                        messageModel.messageType = 1;
                        messageModel.messageLength = 20;
                        messageModel.isRead = true;
                        [timeModel.messageArray addObject:messageModel];
                    }
                        break;
                    case 2: {
                        VKTestMessageModel *messageModel = [[VKTestMessageModel alloc] init];
                        messageModel.nameStr = @"Linda";
                        messageModel.avatarUrl = @"nz-me-avater";
                        messageModel.messageType = 1;
                        messageModel.messageLength = 60;
                        messageModel.isRead = true;
                        [timeModel.messageArray addObject:messageModel];
                    }
                        break;
                    default:
                        break;
                }
            }
        }else if (i == 2) {
            timeModel.messageTime = @"08-08 12：22";
            VKTestMessageModel *messageModel = [[VKTestMessageModel alloc] init];
            messageModel.nameStr = @"Linda";
            messageModel.avatarUrl = @"nz-me-avater";
            messageModel.messageType = 1;
            messageModel.messageLength = 30;
            messageModel.isRead = true;
            [timeModel.messageArray addObject:messageModel];
        }
        [self.kModel.timeArray addObject:timeModel];
    }
    
}

#pragma speakBtnDelegate
- (void)VKAudioStartRecording:(BOOL)isRecording {
    //更新数据
//    VKTestTimeModel *time = self.kModel.timeArray[indexPath.section];
//    VKTestMessageModel *message = time.messageArray[indexPath.row];
    
    for (int i = 0; i < self.kModel.timeArray.count; i++) {
        
        for (int j = 0; j < self.kModel.timeArray[i].messageArray.count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            VKNeZhaChatCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if ([cell isAnimation]) {
                [cell stopAnimation];
            }
        }
    }
}

- (void)VKAudioRecordingFinishWithData:(NSData *)audioData withBodyString:(CGFloat)messageLength {
    if (messageLength > 1) {
        //上传录音数据data
        
        NSLog(@"============%f=============",messageLength);
        //添加假数据
        VKTestMessageModel *messageModel = [[VKTestMessageModel alloc] init];
        messageModel.nameStr = @"Linda";
        messageModel.avatarUrl = @"nz-me-avater";
        messageModel.messageType = 1;
        messageModel.messageLength = messageLength;
        messageModel.isRead = true;
        [self.kModel.timeArray[2].messageArray addObject:messageModel];
        
        [self.tableView reloadData];
        
        //tableView 滚到最下方cell
        //tableview数据刷新完才进行滚动 利用伪延迟解决
        
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            
//            if (self.kModel.timeArray[2].messageArray.count > 1) {
//                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.kModel.timeArray[2].messageArray.count - 2 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//            }
            
            NSInteger rowInteger = self.kModel.timeArray[2].messageArray.count - 1;
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowInteger inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            
        });
    }else{
        NSLog(@"录音时间太短！");
    }
}

@end
