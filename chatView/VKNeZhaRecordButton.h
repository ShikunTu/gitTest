//
//  VKNeZhaRecordButton.h
//  chatView
//
//  Created by tushikun on 2020/7/29.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VKNeZhaRecordButtonDelegate <NSObject>
//录音完成
- (void)VKAudioRecordingFinishWithData:(NSData *_Nullable)audioData withBodyString:(CGFloat)messageLength;
@optional
//开始录音
- (void)VKAudioStartRecording:(BOOL)isRecording;
//录音失败
- (void)VKAudioRecordingFail:(NSString *_Nullable)reason;
//音量值检测
- (void)VKAudioSpeakPower:(float)power;

@end

NS_ASSUME_NONNULL_BEGIN

@interface VKNeZhaRecordButton : UIButton
@property (nonatomic, assign) id<VKNeZhaRecordButtonDelegate>  delegate;
@end

NS_ASSUME_NONNULL_END
