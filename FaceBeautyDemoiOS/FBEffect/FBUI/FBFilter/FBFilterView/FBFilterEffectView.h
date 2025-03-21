//
//  FBFilterEffectView.h
//  FaceBeautyDemo
//


#import <UIKit/UIKit.h>
#import "FBUIConfig.h"

NS_ASSUME_NONNULL_BEGIN
/**
 
    滤镜 功能视图
 
 */

typedef NS_ENUM(NSInteger, FilterType) {
    ht_style_filter = 0, // 风格滤镜
    ht_effect_filter, // 特效滤镜
    ht_haha_filter, // 哈哈镜
};

@interface FBFilterEffectView : UIView

@property (nonatomic, copy) void (^onUpdateSliderHiddenBlock)(FBModel *model,NSInteger index);

- (instancetype)initWithFrame:(CGRect)frame listArr:(NSArray *)listArr;

@property (nonatomic, assign) BOOL isThemeWhite;

// 外部menu点击后刷新collectionview
- (void)updateFilterListData:(NSDictionary *)dic;

/**
 *  通知外部弹框
 */
@property (nonatomic, copy) void (^filterTipBlock)(void);

@end

NS_ASSUME_NONNULL_END
