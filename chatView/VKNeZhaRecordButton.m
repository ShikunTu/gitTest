//
//  VKNeZhaRecordButton.m
//  chatView
//
//  Created by tushikun on 2020/7/29.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import "VKNeZhaRecordButton.h"
#import "VKNeZhaRecordAnimationView.h"
#import "VKNeZhaAudioManager.h"
//  master1
//  master2
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

@interface VKNeZhaRecordButton ()<AVAudioRecorderDelegate>

@property (nonatomic, assign) BOOL  isShouldSendAudioMessage;
@property (nonatomic, assign) NSInteger  audioTimeLength;
@property (nonatomic, strong) VKNeZhaRecordAnimationView  *animationView;

@property (nonatomic, strong) VKNeZhaAudioManager  *audioManager;

@end

@implementation VKNeZhaRecordButton

#pragma mark 懒加载

- (VKNeZhaRecordAnimationView *)animationView {
    if (!_animationView) {
        _animationView = [[VKNeZhaRecordAnimationView alloc] initWithFrame:CGRectMake((Screen_Width - 120)/2, (Screen_Height - 120)/2, 120, 120)];
    }
    return _animationView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundImage:[self imageFromColor:[UIColor colorWithRed:96.f/255.0 green:193.f/255.0 blue:91.f/255.0 alpha:1.0f] size:frame.size] forState:UIControlStateNormal];
        [self setBackgroundImage:[self imageFromColor:[UIColor colorWithRed:51.f/255.0 green:51.f/255.0 blue:51.f/255.0 alpha:0.08f] size:frame.size] forState:UIControlStateHighlighted];
        [self setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3] forState:UIControlStateHighlighted];
        self.layer.cornerRadius = frame.size.height/2;
        self.clipsToBounds = YES;
        
        self.audioManager = [VKNeZhaAudioManager shareInstance];
        [self.audioManager setUpPath];
        
        // 开始
        [self addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
        // 取消
        [self addTarget:self action:@selector(recordCancel:) forControlEvents: UIControlEventTouchUpOutside];
        //完成
        [self addTarget:self action:@selector(recordFinish:) forControlEvents:UIControlEventTouchUpInside];
        //移出
        [self addTarget:self action:@selector(recordTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
        //移入
        [self addTarget:self action:@selector(recordTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    }
    return self;
}

#pragma mark buttonMethod
- (void)recordStart:(UIButton *)button {
    if (![self.audioManager isRecording]) {
        NSLog(@"录音开始");
        
        [self.audioManager startRecord];
        [self setTitle:@"松开 结束" forState:UIControlStateNormal];
        [self setBackgroundImage:[self imageFromColor:[UIColor colorWithRed:51.f/255.0 green:51.f/255.0 blue:51.f/255.0 alpha:0.08f] size:self.frame.size] forState:UIControlStateNormal];
        [self showAnimationView];
        
        if ([self.delegate respondsToSelector:@selector(VKAudioStartRecording:)]) {
            [self.delegate VKAudioStartRecording:YES];
        }
        
    }
}


- (void)recordCancel:(UIButton *)button {
    
    if ([self.audioManager isRecording]) {
        NSLog(@"取消");
        
        [self.audioManager stopRecord];
        [self setBackgroundImage:[self imageFromColor:[UIColor colorWithRed:96.f/255.0 green:193.f/255.0 blue:91.f/255.0 alpha:1.0f] size:self.frame.size] forState:UIControlStateNormal];
        [self setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self hideAnimationView];
        _isShouldSendAudioMessage = NO;
        
    }
    
}

- (void)recordFinish:(UIButton *)button {
    
    if ([self.audioManager isRecording]) {
        NSLog(@"完成");
        
        [self hideAnimationView];
        [self.audioManager stopRecord];
        [self setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setBackgroundImage:[self imageFromColor:[UIColor colorWithRed:96.f/255.0 green:193.f/255.0 blue:91.f/255.0 alpha:1.0f] size:self.frame.size] forState:UIControlStateNormal];
        
        //
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:self.audioManager.filePath]) {
            NSLog(@"文件大小为：%.2llukb", [[manager attributesOfItemAtPath:self.audioManager.filePath error:nil] fileSize]/1024);
            NSData *recordData = [NSData dataWithContentsOfFile:self.audioManager.filePath];
            if ([self.delegate respondsToSelector:@selector(VKAudioRecordingFinishWithData:withBodyString:)]) {
                [self.delegate VKAudioRecordingFinishWithData:recordData withBodyString:[self.audioManager getAudioAllTime]];
            };
            
            
        }
        
        
    }
}

- (void)recordTouchDragExit:(UIButton *)button {
    if([self.audioManager isRecording]) {
        [self setTitle:@"松开 取消" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3] forState:UIControlStateNormal];
        [self.animationView showDragExitView];
        [self.animationView stopAniamtion];
    }
}

- (void)recordTouchDragEnter:(UIButton *)button {
    if([self.audioManager isRecording]) {
        [self setTitle:@"松开 结束" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3] forState:UIControlStateNormal];
        [self.animationView hideDragExitView];
        [self.animationView startAnimation];
    }
}


- (void)showAnimationView {
    __weak typeof(self) weakSelf = self;
//    self.animationView.topCancelImg.hidden = YES;
    self.animationView.itemLevelCallback = ^{
        if ([weakSelf.audioManager isRecording]) {
            
            [weakSelf.audioManager.recorder updateMeters];
            //取得第一个通道的音频，音频强度范围是-160到0
            float power= [weakSelf.audioManager.recorder averagePowerForChannel:0];
            
//            NSLog(@"power ======== %f",power);
            weakSelf.animationView.level = power;
        }
    };
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.animationView];
}

- (void)hideAnimationView {
    
    [self.animationView stopAniamtion];
    [self.animationView removeFromSuperview];
    self.animationView = nil;
}

- (void)audioStart
{
    //开始录音
    NSLog(@"开始录音");
}

//结束录音
- (void)audioStop
{
    NSLog(@"结束录音");
}

//录音失败
- (void)audioFailed
{
    //do something
    NSLog(@"录音失败");
}

//生成纯色图片
- (UIImage*)imageFromColor:(UIColor*)color size:(CGSize)size
{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width,size.height);
    UIGraphicsBeginImageContext(size);//创建图片
    CGContextRef context = UIGraphicsGetCurrentContext();//创建图片上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);//设置当前填充颜色的图形上下文
    CGContextFillRect(context, rect);//填充颜色
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
