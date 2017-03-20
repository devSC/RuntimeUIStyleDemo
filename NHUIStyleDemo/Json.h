//
//  Json.h
//  NHUIStyleDemo
//
//  Created by Wilson-Yuan on 2017/3/20.
//  Copyright © 2017年 Wilson Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Json : NSObject

+ (NSDictionary *)buildClassFromDictionary:(NSArray *)propNames withName:(NSString *)className;

@end
