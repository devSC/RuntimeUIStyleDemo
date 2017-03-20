//
//  NHUIStyle.m
//  NHUIStyleDemo
//
//  Created by Wilson Yuan on 2017/3/20.
//  Copyright © 2017年 Wilson Yuan. All rights reserved.
//

#import "NHUIStyle.h"
#import <objc/runtime.h>


@implementation NHUIStyle

CG_INLINE void swizz_method(Class class, SEL orig_sel, SEL swizzle_sel) {
    
    Method originalMethod = class_getInstanceMethod(class, orig_sel);
    Method swizzledMethod = class_getInstanceMethod(class, swizzle_sel);
    
    BOOL success = class_addMethod(class, orig_sel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzle_sel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _initial];
    }
    return self;
}

- (void)_initial {
    
    //get the propertys list
    unsigned int propertyCount = 0;
    objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);
    //
    for (int i = 0; i < propertyCount; i ++) {
        
        //get a property
        objc_property_t property = propertys[i];
        const char *propertyName = property_getName(property);
        //get property name
        NSString *propertyNameString = [NSString stringWithUTF8String:propertyName];
        
        //
        Class class;
        id value;
        
        //get the property attribuates list
        unsigned int attribuatedCount = 0;
        objc_property_attribute_t *attribuates = property_copyAttributeList(property, &attribuatedCount);
        
        for (int j = 0; j < attribuatedCount; j ++) {
            //get the attribuate
            objc_property_attribute_t attribuate = attribuates[j];
            
            //get attribuate name and value string
            NSString *attribuateNameString = [NSString stringWithUTF8String:attribuate.name];
            NSString *attribuateValueString = [NSString stringWithUTF8String:attribuate.value];
            NSLog(@"%@, name: %@, value: %@", propertyNameString, attribuateNameString, attribuateValueString);
            //is class type
            if ([attribuateNameString isEqualToString:@"T"]) {
                //Get class type string
                NSString *classTypeString = [attribuateValueString substringWithRange:NSMakeRange(2, attribuateValueString.length - 3)];
                //Save the current class
                class = NSClassFromString(classTypeString);
                
                //property name
                //class is UIColor
                if (class == [UIColor class]) {
                    //Save the color
                    value = [self colorWithAttribuateString:propertyNameString];
                }
                //class is UIFont
                else if (class == [UIFont class]) {
                    //Save the font
                    value = [self fontWithAttribuateString:propertyNameString];
                }
                else {
                    NSLog(@"#WARNING----- This property dont supported auto set value: %@ class type: %@",propertyNameString, NSStringFromClass(class));
                }
                break;
            }
        }
        @try {
            NSLog(@"value: %@", value);
            [self setValue:value forKey:propertyNameString];
        } @catch (NSException *exception) {
            //add a fake property
            [self addFakePropertyClass:class withName:propertyNameString value:value];
        } @finally {
            NSLog(@"@finally: %@", propertyNameString);
        }
    }
    free(propertys);
}

id Getter(id item, SEL sel) {
    NSLog(@"class: %@, getter: %@, ", [item class], NSStringFromSelector(sel));
    NSString *var = NSStringFromSelector(sel);
    if (![var hasSuffix:@"_fake"]) {
        var = [var stringByAppendingString:@"_fake"];
    }
    //这里是无法获取fake的成员变量的
//    Ivar ivar = class_getInstanceVariable([item class], [var cStringUsingEncoding:NSUTF8StringEncoding]);
//    return object_getIvar(item, ivar);
    return objc_getAssociatedObject(item, NSSelectorFromString(var));
}

void Setter(id item, SEL sel, id value) {
    //remove prefix 'set'
    NSString *var = [NSStringFromSelector(sel) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    NSString *head = [var substringToIndex:1];
    head = [head lowercaseString];
    var = [var stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
    
    //remove :
    var = [var stringByReplacingCharactersInRange:NSMakeRange([var length] - 1, 1) withString:@""];
    /*
        这里, 不能直接的给现有的类添加属性后得到成员变量. 成员变量只能在类生成之前添加
         const char *name = [[NSString stringWithFormat:@"_%@", var] cStringUsingEncoding:NSUTF8StringEncoding];
     
         Ivar ivar = class_getInstanceVariable([item class], name);
         NSLog(@"class_getInstanceVariable: \n\n class: %@, ivar: %@, value: %@", [item class], ivar, value);
         set value
         object_setIvar(item, ivar, value);
     */
    objc_setAssociatedObject(item, NSSelectorFromString(var), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)setterMethodNameForPropertyName:(NSString *)propertyName {
    NSString *head = [propertyName substringToIndex:1];
    head = [head uppercaseString];
    return [NSString stringWithFormat:@"set%@:", [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head]];
}

- (BOOL)addFakePropertyClass:(Class)propertyClass withName:(NSString *)propertyName value:(id)value {
    
    NSString *fakePropertyName = [propertyName stringByAppendingString:@"_fake"];
    const char *ivarName = [[NSString stringWithFormat:@"_%@", fakePropertyName] cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *classNameChar = [NSString stringWithFormat:@"@\"%@\"", NSStringFromClass(propertyClass)];
    objc_property_attribute_t type = { "T", [classNameChar cStringUsingEncoding:NSUTF8StringEncoding] };
    objc_property_attribute_t ownership = { "R", "" }; // C = copy //R = Readonly
    objc_property_attribute_t backingivar  = { "V", ivarName };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    
    Class class = [self class];
    const char *fakeName = [fakePropertyName cStringUsingEncoding:NSUTF8StringEncoding];
    if (class_addProperty(class, fakeName, attrs, 3)) {
        NSLog(@"add ivar success: %@", fakePropertyName);
    }
    else {
        NSAssert(NO, @"add fake property failed");
    }
    
    NSString *setterString = [self setterMethodNameForPropertyName:fakePropertyName];
    SEL setterMethod = NSSelectorFromString(setterString);
    SEL getterMethod = NSSelectorFromString(fakePropertyName);
    //add setter and getter method
    class_addMethod(class, setterMethod, (IMP)Setter, "v@:@");
    class_addMethod(class, getterMethod, (IMP)Getter, "@@:");
    
    //set value to fake property
    [self setValue:value forKey:fakePropertyName];
    //change the method impletion
    SEL originalGetMethod = NSSelectorFromString(propertyName);
    SEL newGetMethod = NSSelectorFromString(fakePropertyName);
    swizz_method([self class], originalGetMethod, newGetMethod);
    return YES;
}

/**
 *  Reture the color that be from attribuateString containts color info
 *
 *  @param attribuateString color info string eg: color_e399282
 *
 *  @return color
 */
- (UIColor *)colorWithAttribuateString:(NSString *)attribuateString {
    NSArray *strings = [attribuateString componentsSeparatedByString:@"_"];
    UIColor *color;
    if (strings.count == 2) {
        color = [self colorFromHexString:strings.lastObject alpha:1];
    }
    else {
        NSLog(@"WARNING--------- color attribuate string isn't comply with the name regular: %@", attribuateString);
        color = [UIColor blackColor];
    }
    return color;
}

/**
 *  Reture the font that be from attribuateString containts font info
 *
 *  @param attribuateString font regular string eg: font_19
 *
 *  @return font
 */
- (UIFont *)fontWithAttribuateString:(NSString *)attribuateString {
    
    NSArray *strings = [attribuateString componentsSeparatedByString:@"_"];
    NSUInteger fontSize = [strings.lastObject integerValue];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    
    NSString *defaultName = @"PingFangSC-Regular";
    NSString *defaultBoldName = @"PingFangSC-Regular";
    if (strings.count == 2) {
        font = [UIFont fontWithName:defaultName size:fontSize];
    }
    else if (strings.count == 3) { //maybe is the bold font
        if ([[strings[2] lowercaseString] isEqualToString:@"bold"]) {
            font = [UIFont fontWithName:defaultBoldName size:fontSize];
        }
        else {
            font = [UIFont fontWithName:defaultName size:fontSize];
        }
    }
    else if (strings.count == 4){
        //IS Custome Bold
        NSString *fontFamily = strings[2];
        NSString *fontStyle = strings[3];
        NSString *fontName = [NSString stringWithFormat:@"%@-%@", fontFamily, fontStyle];
        font = [UIFont fontWithName:fontName size:fontSize];
    }
    else {
        NSLog(@"#WARNING-----font not supported : %@", attribuateString);
    }
    
    if (!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    return font;
}

/**
 *  color convinence init method
 *
 *  @param hexString color hex string
 *  @param alpha     alpha
 *
 *  @return color
 */
- (UIColor *)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    
    unsigned rgbValue = 0;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

@end
