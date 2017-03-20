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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //
    NHUIStyle *style = [[NHUIStyle alloc] init];
    NSLog(@"\n\nblueColor_3793fe: %@, redColor_f04f4f: %@\n\n",style.blueColor_3793fe ,style.redColor_f04f4f);
    self.view.backgroundColor = style.blueColor_3793fe;
    
    NHUIStyle *newStyle = [[NHUIStyle alloc] init];
    NSLog(@"\n\nblueColor_3793fe: %@, redColor_f04f4f: %@\n\n",newStyle.blueColor_3793fe ,newStyle.redColor_f04f4f);
    self.view.backgroundColor = newStyle.redColor_f04f4f;
    
//    [SomeClass dynamicInject];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
