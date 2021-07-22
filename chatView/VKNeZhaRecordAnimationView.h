//
//  VKNeZhaRecordAnimationView.h
//  chatView
//
//  Created by tushikun on 2020/7/29.
//  Copyright © 2020 tushikun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKNeZhaRecordAnimationView : UIView

@property (nonatomic, copy) void (^itemLevelCallback)(void);

@property (nonatomic) CGFloat level;


- (void)startAnimation;
- (void)stopAniamtion;

- (void)showDragExitView;
- (void)hideDragExitView;
@end

NS_ASSUME_NONNULL_END
