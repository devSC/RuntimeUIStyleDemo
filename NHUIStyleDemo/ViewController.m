//
//  ViewController.m
//  NHUIStyleDemo
//
//  Created by Wilson Yuan on 2017/3/20.
//  Copyright © 2017年 Wilson Yuan. All rights reserved.
//

#import "ViewController.h"
#import "NHUIStyle+time.h"
#import "SomeClass.h"
#import "Json.h"

#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //
    NHUIStyle *style = [[NHUIStyle alloc] init];
    NSLog(@"\n\nblueColor_3793fe: %@, redColor_f04f4f: %@\n\n",style.blueColor_3793fe ,style.redColor_f04f4f);
    self.view.backgroundColor = style.redColor_f04f4f;
    
    
//    [SomeClass dynamicInject];
    
    /*
    [Json buildClassFromDictionary:@[@"FirstName", @"LastName", @"Age", @"Gender"] withName:@"Person"];
    unsigned int propertyCount = 0;
    objc_property_t *propertys = class_copyPropertyList(NSClassFromString(@"Person"), &propertyCount);
    for (int i = 0; i < propertyCount; i ++) {
        objc_property_t property = propertys[i];
        const char *propertyName = property_getName(property);
        NSLog(@"propertyName: %s", propertyName);
    }
     */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
