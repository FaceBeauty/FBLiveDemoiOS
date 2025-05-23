//
//  FBBeautyEffectView.h
//  FaceBeautyDemo
//
//  Created by Texeljoy Tech on 2022/7/19.
//

#import <UIKit/UIKit.h>
#import "FBUIConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 
    美肤、美型 功能视图
 
 */
@interface FBBeautyEffectView : UIView

@property (nonatomic,copy) void (^onClickResetBlock)(void);
@property (nonatomic,copy) void (^onUpdateSliderHiddenBlock)(FBModel *model);

- (instancetype)initWithFrame:(CGRect)frame listArr:(NSArray *)listArr;
- (void)updateResetButtonState:(BOOL)state;
- (void)clickResetSuccess;

/**
 *
 *  外部menu点击后的刷新collectionview
 *
 *  @prama dic 数据
 */
- (void)updateBeautyAndShapeEffectData:(NSDictionary *)dic;
    
@property (nonatomic, assign) BOOL isThemeWhite;

@end

NS_ASSUME_NONNULL_END
