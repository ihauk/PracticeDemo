//
//  ViewController.m
//  SelfieDemo
//
//  Created by zhuhao on 14/12/2.
//  Copyright (c) 2014年 pinguo. All rights reserved.
//

#import "ViewController.h"
#import "PGTumblrMenuView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *showButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [_showButton addTarget:self action:@selector(showItem) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showItem{
    
    PGTumblrMenuView *menuView = [[PGTumblrMenuView alloc]init];
    [menuView addMenuItemWithTitle:@"Text" andIcon:@"post_type_bubble_text.png" andHeightLightIcon:nil andSelectedBlock:^{
        NSLog(@"select");
    }];
    [menuView addMenuItemWithTitle:@"Text" andIcon:@"post_type_bubble_text.png" andHeightLightIcon:nil andSelectedBlock:^{
        NSLog(@"select");
    }];
    [menuView addMenuItemWithTitle:@"Text" andIcon:@"post_type_bubble_photo.png" andHeightLightIcon:nil andSelectedBlock:^{
        NSLog(@"select");
    }];
    
    [self.view addSubview:menuView];
    
    [menuView show];

}

@end
