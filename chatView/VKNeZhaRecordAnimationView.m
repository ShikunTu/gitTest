//
//  VKNeZhaRecordAnimationView.m
//  chatView
//
//  Created by tushikun on 2020/7/29.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import "VKNeZhaRecordAnimationView.h"

#define leftMargin 25.0
#define TopViewWid CGRectGetHeight(self.bounds) - leftMargin*2

@interface VKNeZhaRecordAnimationView ()
//动画的属性
@property (nonatomic) NSUInteger numberOfItems;
@property (nonatomic) UIColor * itemColor;
@property (nonatomic, strong) NSMutableArray * levels;
@property (nonatomic, strong) NSMutableArray * itemLineLayers;

@property (nonatomic) CGFloat itemHeight;
@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) CGFloat lineWidth;//自适应

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIView  *topView;

//控件
@property (nonatomic, strong) UILabel  *bottomLabel; //松开取消发送
@property (nonatomic, strong) UIButton  *topCancelImg;//取消的图片

@end

@implementation VKNeZhaRecordAnimationView

//改为UIImageView
- (UIButton *)topCancelImg {
    if (!_topCancelImg) {
        _topCancelImg = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, 0, TopViewWid, TopViewWid)];
        [_topCancelImg setImage:[UIImage imageNamed:@"record_cancel"] forState:UIControlStateNormal];
        _topCancelImg.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _topCancelImg.userInteractionEnabled = NO;
    }
    return _topCancelImg;
}

- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.text = @"上滑取消发送";
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
        _bottomLabel.textColor = [UIColor whiteColor];
        _bottomLabel.frame = CGRectMake(0, TopViewWid, CGRectGetWidth(self.bounds), 15.0);
        
    }
    return _bottomLabel;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.frame = CGRectMake(leftMargin, 0, TopViewWid, TopViewWid);
        _topView.backgroundColor = [UIColor clearColor];
    }
    return _topView;
}

#pragma mark - 初始化
- (id)init {
    if(self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]){
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

//设置基本信息
- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:58.f/255.0 green:58.f/255.0 blue:58.f/255.0 alpha:1.0f];
    self.alpha = 0.9;
    self.layer.cornerRadius = 5.f;
    self.clipsToBounds = YES;
    self.numberOfItems = 22.f;//偶数
    self.itemColor = [UIColor whiteColor];
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomLabel];
    [self addSubview:self.topCancelImg];
    self.topCancelImg.hidden = YES;
    
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.itemHeight = CGRectGetHeight(self.topView.bounds);
    self.itemWidth = CGRectGetWidth(self.topView.bounds);
    self.lineWidth = self.itemWidth / self.numberOfItems;
}

#pragma mark - setter
- (void)setItemColor:(UIColor *)itemColor {
    _itemColor = itemColor;
    for (CAShapeLayer *itemLine in self.itemLineLayers) {
        itemLine.strokeColor = [self.itemColor CGColor];
    }
}

- (void)setNumberOfItems:(NSUInteger)numberOfItems {
    if (_numberOfItems == numberOfItems) {
        return;
    }
    _numberOfItems = numberOfItems;

    self.levels = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < self.numberOfItems / 2 ; i++){
        [self.levels addObject:@(0)];
    }

    for (CAShapeLayer *itemLine in self.itemLineLayers) {
        [itemLine removeFromSuperlayer];
    }
    self.itemLineLayers = [NSMutableArray array];
    for(int i=0; i < numberOfItems; i++) {
        CAShapeLayer *itemLine = [CAShapeLayer layer];
        itemLine.lineCap       = kCALineCapRound;
        itemLine.lineJoin      = kCALineJoinRound;
        itemLine.strokeColor   = [[UIColor clearColor] CGColor];
        itemLine.fillColor     = [[UIColor clearColor] CGColor];
        itemLine.strokeColor   = [self.itemColor CGColor];
        itemLine.lineWidth     = self.lineWidth;

        [self.layer addSublayer:itemLine];
        [self.itemLineLayers addObject:itemLine];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    if (_lineWidth != lineWidth) {
        _lineWidth = lineWidth;
        for (CAShapeLayer *itemLine in self.itemLineLayers) {
            itemLine.lineWidth = lineWidth;
        }
    }
}

- (void)setItemLevelCallback:(void (^)(void))itemLevelCallback {
    _itemLevelCallback = itemLevelCallback;
    [self startAnimation];
}

- (void)setLevel:(CGFloat)level {
    level = (level+37.5)*3.2;
    if( level < 0 ) level = 0;
    [self.levels removeObjectAtIndex:self.numberOfItems/2-1];
    [self.levels insertObject:@(level / 6.f) atIndex:0];
    [self updateItems];
    
}


#pragma mark - update
- (void)updateItems {
    UIGraphicsBeginImageContext(self.topView.frame.size);
    int lineOffset = self.lineWidth * 2.f;
    int leftX = (self.itemWidth + leftMargin + self.lineWidth/2);

    for(int i = 0; i < self.numberOfItems / 2; i++) {
        CGFloat lineHeight = self.lineWidth + [self.levels[i] floatValue] * self.lineWidth *2;
        NSLog(@"level=====%f======",[self.levels[i] floatValue]);
        CGFloat lineTop = (self.itemHeight - lineHeight/2) / 2.f;
        CGFloat lineBottom = (self.itemHeight + lineHeight/2) / 2.f;
        
        leftX -= lineOffset;
        UIBezierPath *linePathLeft = [UIBezierPath bezierPath];
      
        [linePathLeft moveToPoint:CGPointMake(leftX, lineTop)];
        [linePathLeft addLineToPoint:CGPointMake(leftX, lineBottom)];
       
        
        CAShapeLayer *itemLine2 = [self.itemLineLayers objectAtIndex:i + self.numberOfItems / 2];
        itemLine2.path = [linePathLeft CGPath];
    }
    UIGraphicsEndImageContext();
}


#pragma mark - 开始停止动画
- (void)startAnimation {
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:_itemLevelCallback selector:@selector(invoke)];
        self.displayLink.preferredFramesPerSecond = 8.f;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)stopAniamtion {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

#pragma mark 手指上滑操作
- (void)showDragExitView {
    self.topCancelImg.hidden = NO;
    self.topView.hidden = YES;
    self.bottomLabel.text = @"松开取消发送";
    self.itemColor = [UIColor clearColor];
}

- (void)hideDragExitView {
    self.topCancelImg.hidden = YES;
    self.topView.hidden = NO;
    self.bottomLabel.text = @"上滑取消发送";
    self.itemColor = [UIColor whiteColor];
}
@end
