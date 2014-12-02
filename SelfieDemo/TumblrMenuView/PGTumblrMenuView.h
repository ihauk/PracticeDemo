//
//  PGTumblrMenuView.h
//  SelfieDemo
//
//  Created by zhuhao on 14/12/2.
//  Copyright (c) 2014年 pinguo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PGTumblrMenuItemSelectedBlock)(void);

@interface PGTumblrMenuView : UIView

- (void)addMenuItemWithTitle:(NSString*)title
                      andIcon:(NSString*)iconName
           andHeightLightIcon:(NSString*)hgightIcon
             andSelectedBlock:(PGTumblrMenuItemSelectedBlock)selectBlock;

- (void)show;

@end
