//
//  VKNeZhaChatCell.m
//  chatView
//
//  Created by tushikun on 2020/7/30.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import "VKNeZhaChatCell.h"
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define MAX_MESSAGEBTN_WIDTH 186
#define MIN_MESSAGEBTN_WIDTH 45

typedef  NS_ENUM(NSInteger,BubbleCornerType) {
    // 左气泡
    BubbleCornerTypeTeacher = 0,
    // 右气泡
    BubbleCornerTypeStudent = 1
};

@interface VKNeZhaChatCell ()
@property (nonatomic, strong) UIImageView  *headImg;
@property (nonatomic, strong) UIButton  *messageBtn;
@property (nonatomic, strong) UILabel  *nameLabel;
@property (nonatomic, strong) UILabel  *timeLabel;
@property (nonatomic, strong) UIView  *redPoint;

@property (nonatomic, strong) UIImageView  *waveImage;
@end

@implementation VKNeZhaChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self loadSubviews];
    }
    return self;
}
//设置布局
- (void)loadSubviews {
    //头像
    self.headImg = [[UIImageView alloc] init];
    [self.contentView addSubview:self.headImg];
    self.headImg.frame = CGRectMake(14, 15, 33.5, 33.5);
    self.headImg.layer.cornerRadius = 33.5/2;
    self.headImg.clipsToBounds = YES;
    [self.headImg setImage:[UIImage imageNamed:@"nz_teacher_avatar"]];
    
    //名称
    self.nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.nameLabel];
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headImg.frame) + 4, CGRectGetMinX(self.headImg.frame) + 3, 50, 15);
    self.nameLabel.text = @"辅导老师";
    self.nameLabel.font = [UIFont systemFontOfSize:11];
    self.nameLabel.alpha = 0.7;
    
    //聊天气泡
    self.messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.messageBtn];
    self.messageBtn.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame) + 3, MAX_MESSAGEBTN_WIDTH, 34);
    [self.messageBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.messageBtn.backgroundColor = [UIColor colorWithRed:118.f/255.0 green:217.f/255.0 blue:112.f/255.0 alpha:1.f];
    self.messageBtn.layer.mask = [self makeBubbleCornerWithType:BubbleCornerTypeTeacher];
    //红点
    UIView *redPoint = [[UIView alloc] init];
    redPoint.backgroundColor = [UIColor redColor];
    redPoint.layer.cornerRadius = 7/2;
    redPoint.clipsToBounds = YES;
    [self.contentView addSubview:redPoint];
    self.redPoint = redPoint;
    redPoint.frame = CGRectMake(CGRectGetMaxX(self.messageBtn.frame) - 7 - 1, CGRectGetMinY(self.messageBtn.frame), 7, 7);
    [self.contentView bringSubviewToFront:redPoint];
    
    
    //时长
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.text = @"58″";
    self.timeLabel.textColor = [UIColor colorWithRed:169.f/255.0 green:169.f/255.0 blue:169.f/255.0 alpha:1.f];
    [self.contentView addSubview:self.timeLabel];
    self.timeLabel.font = [UIFont systemFontOfSize:11.f];
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.messageBtn.frame) + 4, CGRectGetMinY(self.messageBtn.frame), 25.5, CGRectGetHeight(self.messageBtn.frame));
    
    //声波动画
    self.waveImage = [[UIImageView alloc] init];
    [self.contentView addSubview:self.waveImage];
    self.waveImage.frame = CGRectMake(CGRectGetMinX(self.messageBtn.frame) + 14.5, CGRectGetMinY(self.messageBtn.frame) + (CGRectGetHeight(self.messageBtn.frame) - 15.5)/2, 11.0, 15.5);
    [self.waveImage setImage:[UIImage imageNamed:@"sound_wave"]];
    self.waveImage.animationDuration = 0.85f;
    self.waveImage.animationRepeatCount = 0;
        //  动态效果
    NSUInteger imgCount = 3;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:imgCount];
    for (NSUInteger index = 0; index < imgCount; index++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"sound_wave_%02lu@2x.png", (unsigned long)index]];
        [arr addObject:img];
    }
    self.waveImage.animationImages = arr.copy;
}

//画气泡圆角
- (CAShapeLayer *)makeBubbleCornerWithType:(BubbleCornerType)type {
    //画两个圆角
    CGFloat radius = 34/2; // 圆角大小
    UIRectCorner corner;
    if (type == BubbleCornerTypeTeacher) {
        corner = UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight; // 左类型气泡
    }else {
        corner = UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight; // 右类型气泡
    }
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.messageBtn.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.messageBtn.bounds;
    maskLayer.path = path.CGPath;
    return maskLayer;
}

//刷新数据
- (void)reloadDataWithModel:(VKTestMessageModel *)model {
    CGFloat messageBtnWid;
    if (model.messageLength >= 60) {
        messageBtnWid = MAX_MESSAGEBTN_WIDTH;
    }
    else if (model.messageLength <= 15){
        messageBtnWid = MIN_MESSAGEBTN_WIDTH;
    }
    else{
        CGFloat scale = (CGFloat)(((float)model.messageLength) / 60);
        messageBtnWid = MAX_MESSAGEBTN_WIDTH * scale;
    }
    
    //根据type更新位置
    if (model.messageType == 0) {
        self.headImg.frame = CGRectMake(14, 15, 33.5, 33.5);
        self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headImg.frame) + 4, CGRectGetMinX(self.headImg.frame) + 3, 50, 15);
        self.messageBtn.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame) + 3, messageBtnWid, 34);
        self.redPoint.frame = CGRectMake(CGRectGetMaxX(self.messageBtn.frame) - 7 - 1, CGRectGetMinY(self.messageBtn.frame), 7, 7);
        self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.messageBtn.frame) + 4, CGRectGetMinY(self.messageBtn.frame), 80, CGRectGetHeight(self.messageBtn.frame));
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        
        self.waveImage.frame = CGRectMake(CGRectGetMinX(self.messageBtn.frame) + 14.5, CGRectGetMinY(self.messageBtn.frame) + (CGRectGetHeight(self.messageBtn.frame) - 15.5)/2, 11.0, 15.5);
        
        self.messageBtn.layer.mask = [self makeBubbleCornerWithType:BubbleCornerTypeTeacher];
        
    }else{
        self.headImg.frame = CGRectMake(Screen_Width - 14 - 33.5, 15, 33.5, 33.5);
        self.nameLabel.frame = CGRectMake(CGRectGetMinX(self.headImg.frame) - 50 - 4, CGRectGetMinY(self.headImg.frame) + 3, 50, 15);
        self.messageBtn.frame = CGRectMake(CGRectGetMinX(self.headImg.frame) - messageBtnWid - 4, CGRectGetMaxY(self.nameLabel.frame) + 3, messageBtnWid, 34);
        self.redPoint.frame = CGRectMake(0, 0, 0, 0);
        self.timeLabel.frame = CGRectMake(CGRectGetMinX(self.messageBtn.frame) - 4 - 80, CGRectGetMinY(self.messageBtn.frame), 80, CGRectGetHeight(self.messageBtn.frame));
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        
        self.waveImage.frame = CGRectMake(CGRectGetMaxX(self.messageBtn.frame) - 14.5 - 11, CGRectGetMinY(self.messageBtn.frame) + (CGRectGetHeight(self.messageBtn.frame) - 15.5)/2, 11.0, 15.5);
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        self.waveImage.transform = transform;
        
        self.messageBtn.layer.mask = [self makeBubbleCornerWithType:BubbleCornerTypeStudent];
    }
    
    //设置头像
    [self.headImg setImage:[UIImage imageNamed:model.avatarUrl]];
    self.nameLabel.text = model.nameStr;
    
    self.timeLabel.text = model.messageLength > 60 ? [NSString stringWithFormat:@"%ld″%ld",(long)(model.messageLength/60),(long)(model.messageLength%60)] : [NSString stringWithFormat:@"%ld″",(long)model.messageLength];
    
    if (model.isRead) {
        self.redPoint.hidden = true;
    }else{
        self.redPoint.hidden = false;
    }
    
    if (self.waveImage.image == [UIImage imageNamed:@""]) {
        [self.waveImage startAnimating];
    }
}

//防止复用控件
- (void)prepareForReuse {
    [super prepareForReuse];
}

//点击事件
- (void)buttonClick:(UIButton *) sender {
    if ([self.waveImage isAnimating]) {
        [self stopAnimation];
    }else{
        [self startAnimation];
    }
    
    if (self.messageBtnClick) {
        self.messageBtnClick();
    }
}


- (void)startAnimation {
    if (![self.waveImage isAnimating]) {
        [self.waveImage startAnimating];
        [self.waveImage setImage:[UIImage imageNamed:@""]];
    }
}
- (void)stopAnimation {
    if ([self.waveImage isAnimating]) {
        [self.waveImage stopAnimating];
        [self.waveImage setImage:[UIImage imageNamed:@"sound_wave"]];
    }
}

- (BOOL)isAnimation {
    return [self.waveImage isAnimating];
}

@end
