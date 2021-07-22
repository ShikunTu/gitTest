//
//  VKNeZhaAudioManager.h
//  chatView
//
//  Created by tushikun on 2020/7/31.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface VKNeZhaAudioManager : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>


@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, copy) NSURL *recordFileUrl;
@property (nonatomic, copy) NSString *filePath;
 
+ (instancetype)shareInstance;

- (NSString *)setUpPath;
 
- (void)startRecord;
 
- (void)pauseRecord;
 
- (void)continueRecordd;
 
- (void)stopRecord;
 
- (float)getAudioAllTime;

- (BOOL)isRecording;

@end

NS_ASSUME_NONNULL_END
