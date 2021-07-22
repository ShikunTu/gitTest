//
//  VKNeZhaAudioManager.m
//  chatView
//
//  Created by tushikun on 2020/7/31.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import "VKNeZhaAudioManager.h"


#define AudioType @"aac"

@interface VKNeZhaAudioManager ()

@end

@implementation VKNeZhaAudioManager

+ (instancetype)shareInstance {
    static VKNeZhaAudioManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VKNeZhaAudioManager alloc] init];
    });
    return manager;
}

- (NSString *)setUpPath
{
    //  在Documents目录下创建一个名为FileData的文件夹
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"AudioData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir)) {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
        NSLog(@"创建文件夹成功，文件路径%@",path);
    }
    path = [path stringByAppendingPathComponent:@"myRecord.aac"];
    self.filePath = path;
    NSLog(@"录音文件保存地址------->%@",path);
    NSURL *url=[NSURL fileURLWithPath:path];
    self.recordFileUrl = url;
    return path;
}
 
 
- (AVAudioRecorder *)recorder
{
    if (!_recorder) {
        
        AVAudioSession *sessionTemp =[AVAudioSession sharedInstance];
        NSError *sessionError;
        [sessionTemp setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if (sessionTemp == nil) {
            NSLog(@"Error creating session: %@",[sessionError description]);
            return nil;
        }else{
            [sessionTemp setActive:YES error:nil];
        }
        self.session = sessionTemp;
        //创建录音格式设置
        NSDictionary *setting = [self getAudioSetting];
        //创建录音机
        NSError *error = nil;
        _recorder = [[AVAudioRecorder alloc]initWithURL:self.recordFileUrl settings:setting error:&error];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
        
        NSLog(@"recorder 创建完成:%@",self.recordFileUrl);
        
//        [_recorder prepareToRecord];
        
        NSLog(@"recorder prepare");
    }
    return _recorder;
    
}
 
- (NSDictionary *)getAudioSetting
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //采样率  8000/11025/22050/44100/96000（影响音频的质量）
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    // 编码格式
    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    // 录音质量
    [dicM setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
    // 每个采样点位
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    // 浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    
    return dicM;
}
 
- (BOOL)isRecording {
    return self.recorder.isRecording;
}


- (void)startRecord
{
    if ([self.recorder isRecording]) {
        [self.recorder stop];
        [self.recorder record];
    } else {
        [self.recorder record];
    }
}
 
- (void)pauseRecord
{
    if ([self.recorder isRecording]) {
        [self.recorder pause];
    }
}
 
- (void)continueRecordd
{
    [self startRecord];
}
 
- (void)stopRecord
{
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:self.filePath]) {
        NSLog(@"文件大小为：%.2llukb", [[manager attributesOfItemAtPath:self.filePath error:nil] fileSize]/1024);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"文件时长为：%.f", [self getAudioAllTime]);
    });
}
 
- (float)getAudioAllTime
{
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:self.recordFileUrl options:nil];
    CMTime duration = audioAsset.duration;
    NSInteger resultTime = 0;
    resultTime = CMTimeGetSeconds(duration);
    return resultTime;
}

@end
