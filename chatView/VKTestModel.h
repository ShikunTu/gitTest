//
//  VKTestModel.h
//  chatView
//
//  Created by tushikun on 2020/7/30.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKTestMessageModel : NSObject
@property (nonatomic, copy) NSString  *avatarUrl;
@property (nonatomic, copy) NSString  *nameStr;
@property (nonatomic, assign) NSInteger  messageType;
@property (nonatomic, assign) NSInteger  messageLength;
@property (nonatomic, assign) BOOL  isRead;
@end

@interface VKTestTimeModel : NSObject
@property (nonatomic, copy) NSString  *messageTime;
@property (nonatomic, strong) NSMutableArray<VKTestMessageModel *>  *messageArray;
@end

@interface VKTestModel : NSObject
@property (nonatomic, strong) NSMutableArray<VKTestTimeModel *>  *timeArray;
@end

NS_ASSUME_NONNULL_END
