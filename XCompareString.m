//
//  XCompareString.m
//  zyt-ios
//
//  Created by xinyu_mac on 17/3/2.
//  Copyright © 2017年 tcxy. All rights reserved.
//

#import "XCompareString.h"

#define ENGLISH @"[a-zA-Z]"
#define CHINESE @"[\u4e00-\u9fa5]"
#define INTSTR @"[0-9]"
#define SMALLLETTER @"[a-z]"

@interface XCompareString ()

@property (nonatomic, strong) NSMutableArray *tempChineseArray;
@property (nonatomic, strong) NSMutableArray *tempChineseArray1;

@end

@implementation XCompareString

#pragma mark - 接口相关
/**获取排序*/
- (NSMutableArray *)getCompareDateWithArray:(NSMutableArray *) mutableArray
{
    NSMutableArray *tempMutableArray = [self compareAllWithArray:mutableArray];
    for (int i = 0; i < self.tempChineseArray.count; i++) {
        for (int j = 0; j < tempMutableArray.count; j++) {
            if ([self.tempChineseArray[i] isEqualToString:tempMutableArray[j]]) {
                tempMutableArray[j] = self.tempChineseArray1[i];
            }
        }
    }
    return tempMutableArray;
}

/**获取分组*/
- (NSMutableArray *)getDivideGroupsWithArray:(NSMutableArray *) mutableArray
{
    NSMutableArray *tempMutableArray = [self getDivideGroupsHeadWithArray:[self compareAllWithArray:mutableArray]];
    for (int i = 0; i < self.tempChineseArray.count; i++) {
        for (int j = 0; j < tempMutableArray.count; j++) {
            for (int k = 0; k < [tempMutableArray[j] count]; k++) {
                if ([self.tempChineseArray[i] isEqualToString:tempMutableArray[j][k]]) {
                    tempMutableArray[j][k] = self.tempChineseArray1[i];
                }
            }
        }
    }
    return tempMutableArray;
}

#pragma mark - 数据处理
/**获取分组头*/
- (NSMutableArray *)getDivideGroupsHeadWithArray:(NSMutableArray *) mutableArray
{
    NSMutableArray *tempDateMArray = [NSMutableArray array];
    NSMutableArray *tempDateMArray1 = [NSMutableArray array];
    NSMutableArray *tempIndexMArray = [NSMutableArray array];
    NSString *tempIndexStr = [mutableArray[0] substringToIndex:1];
    if ([self typeJudgeWithStr:tempIndexStr withType:SMALLLETTER]) {
        tempIndexStr = tempIndexStr.uppercaseString;
    }
    [tempIndexMArray addObject:tempIndexStr];
    [tempDateMArray addObject:mutableArray[0]];
    if (mutableArray.count == 1) {
        [tempDateMArray1 addObject:tempDateMArray.mutableCopy];
    }
    for (int i = 0; i < mutableArray.count-1; i++) {
        NSString *tempStr = [mutableArray[i+1] substringToIndex:1];
        if ([self typeJudgeWithStr:tempStr withType:SMALLLETTER]) {
            tempStr = tempStr.uppercaseString;
        }
        if (![tempIndexStr isEqualToString:tempStr]) {
            tempIndexStr = tempStr;
            [tempIndexMArray addObject:tempStr];
            [tempDateMArray1 addObject:tempDateMArray.mutableCopy];
            [tempDateMArray removeAllObjects];
        }
        [tempDateMArray addObject:mutableArray[i+1]];
        if (i == mutableArray.count-2) {
            [tempDateMArray1 addObject:tempDateMArray.mutableCopy];
        }
//        NSLog(@"tempDateMArray == %@", mutableArray[i]);
    }
    self.indexMArray = tempIndexMArray;
    return tempDateMArray1;
}

/**进行排序*/
- (NSMutableArray *)compareAllWithArray:(NSMutableArray *) mutableArray
{
    NSMutableArray *tempMutableArray = [NSMutableArray array];
    if (mutableArray.count) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        [mutableArray sortUsingDescriptors:@[sortDescriptor]];
        NSMutableArray *mArray = [self getFirstStrWithArray:mutableArray];
        NSMutableArray *chineseArray = [NSMutableArray array];
        NSMutableArray *englishArray = [NSMutableArray array];
        NSMutableArray *intArray = [NSMutableArray array];
        NSMutableArray *otherArray = [NSMutableArray array];
        for (int i = 0; i < mArray.count; i++) {
            if ([self typeJudgeWithStr:mArray[i] withType:CHINESE]) {
                [chineseArray addObject:mutableArray[i]];
            }
            else if ([self typeJudgeWithStr:mArray[i] withType:ENGLISH]) {
                [englishArray addObject:mutableArray[i]];
            }
            else if ([self typeJudgeWithStr:mArray[i] withType:INTSTR]) {
                [intArray addObject:mutableArray[i]];
            }
            else {
                [otherArray addObject:mutableArray[i]];
            }
        }
        self.tempChineseArray = [self chineseForPinyinWithArray:chineseArray];
        for (int i = 0; i < self.tempChineseArray.count; i++) {
            [self.tempChineseArray1 addObject:chineseArray[i]];
        }
        [englishArray addObjectsFromArray:self.tempChineseArray];
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        [englishArray sortUsingDescriptors:@[sortDescriptor1]];
        [tempMutableArray addObjectsFromArray:englishArray];
        [tempMutableArray addObjectsFromArray:intArray];
        [tempMutableArray addObjectsFromArray:otherArray];
    }
    return tempMutableArray;
}

/**获取首字符*/
- (NSMutableArray *)getFirstStrWithArray:(NSMutableArray *) mutableArray
{
    NSMutableArray *tempMutableArray = [NSMutableArray array];
    if (mutableArray.count) {
        for (int i = 0; i < mutableArray.count; i++) {
            [tempMutableArray addObject:[mutableArray[i] substringToIndex:1]];
        }
    }
    return tempMutableArray;
}

/**汉字转拼音*/
- (NSMutableArray *)chineseForPinyinWithArray:(NSMutableArray *) mutableArray
{
    NSMutableArray *pinyinStrArray = [NSMutableArray array];
    if (mutableArray.count) {
        for (int i = 0; i < mutableArray.count; i++) {
            NSMutableString *tempStr = [NSMutableString stringWithString:mutableArray[i]];
            CFStringTransform((CFMutableStringRef)tempStr, NULL, kCFStringTransformToLatin, false);
            CFStringTransform((CFMutableStringRef)tempStr, NULL, kCFStringTransformStripDiacritics, false);
//            tempStr1 = (NSMutableString *)[tempStr1 stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([self typeJudgeWithStr:[tempStr substringToIndex:1] withType:SMALLLETTER]) {
                tempStr = (NSMutableString *)tempStr.uppercaseString;
            }
            [pinyinStrArray addObject:tempStr];
        }
    }
    return pinyinStrArray;
}

/**字符类型判断*/
- (BOOL)typeJudgeWithStr:(NSString *) str withType:(NSString *) strRegex
{
    NSPredicate *strPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegex];
    return [strPredicate evaluateWithObject:str];
}

#pragma mark - 懒加载相关
- (NSMutableArray *)tempChineseArray
{
    if (!_tempChineseArray) {
        _tempChineseArray = [NSMutableArray array];
    }
    return _tempChineseArray;
}

- (NSMutableArray *)tempChineseArray1
{
    if (!_tempChineseArray1) {
        _tempChineseArray1 = [NSMutableArray array];
    }
    return _tempChineseArray1;
}

@end
