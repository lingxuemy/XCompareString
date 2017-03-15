//
//  XCompareString.h
//  zyt-ios
//
//  Created by xinyu_mac on 17/3/2.
//  Copyright © 2017年 tcxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCompareString : NSObject

/**分组标题字母*/
@property (nonatomic, copy) NSMutableArray *indexMArray;

/**获取排序*/
- (NSMutableArray *)getCompareDateWithArray:(NSMutableArray *) mutableArray;

/**获取分组*/
- (NSMutableArray *)getDivideGroupsWithArray:(NSMutableArray *) mutableArray;

@end
