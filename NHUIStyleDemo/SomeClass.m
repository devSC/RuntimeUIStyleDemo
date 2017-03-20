//
//  SomeClass.m
//  NHUIStyleDemo
//
//  Created by Wilson Yuan on 2017/3/20.
//  Copyright © 2017年 Wilson Yuan. All rights reserved.
//

#import "SomeClass.h"
#import <objc/runtime.h>


@implementation SomeClass

- (id)init {
    self = [super init];
    if (self) {
    _privateName = @"Steve";
    }
    return self;
}

NSString *nameGetter(id self, SEL _cmd) {
    Ivar ivar = class_getInstanceVariable([SomeClass class], "_privateName");
    return object_getIvar(self, ivar);
}

void nameSetter(id self, SEL _cmd, NSString *newName) {
    Ivar ivar = class_getInstanceVariable([SomeClass class], "_privateName");
    id oldName = object_getIvar(self, ivar);
    if (oldName != newName) object_setIvar(self, ivar, [newName copy]);
}


+ (void)dynamicInject {

    objc_property_attribute_t type = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backingivar  = { "V", "_privateName" };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    class_addProperty([SomeClass class], "name", attrs, 3);
    class_addMethod([SomeClass class], @selector(name), (IMP)nameGetter, "@@:");
    class_addMethod([SomeClass class], @selector(setName:), (IMP)nameSetter, "v@:@");
    
    id o = [SomeClass new];
    NSLog(@"%@", [o name]);
    [o setName:@"Jobs"];
    NSLog(@"%@", [o name]);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
