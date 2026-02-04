//
//  FBModel.m
//  FaceBeautyDemo
//
//  Created by Texeljoy Tech on 2022/7/18.
//

#import "FBModel.h"
#import "FBTool.h"

@implementation FBModel

- (instancetype)initWithDic:(NSDictionary *)dic{
    
    if (self = [super init]) {
        // KVC赋值
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
    
}

@end
