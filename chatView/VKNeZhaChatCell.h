//
//  VKNeZhaChatCell.h
//  chatView
//
//  Created by tushikun on 2020/7/30.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKTestModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKNeZhaChatCell : UITableViewCell

@property (nonatomic, copy) void(^messageBtnClick)(void);
- (void)reloadDataWithModel:(VKTestMessageModel *)model;

- (void)startAnimation;
- (void)stopAnimation;
- (BOOL)isAnimation;
@end

NS_ASSUME_NONNULL_END
