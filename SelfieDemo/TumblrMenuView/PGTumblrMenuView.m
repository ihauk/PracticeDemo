//
//  PGTumblrMenuView.m
//  SelfieDemo
//
//  Created by zhuhao on 14/12/2.
//  Copyright (c) 2014年 pinguo. All rights reserved.
//

#import "PGTumblrMenuView.h"

#define kColumnCount 3
#define CHTumblrMenuViewImageHeight 90
#define CHTumblrMenuViewTitleHeight 20
#define CHTumblrMenuViewVerticalPadding 10
#define CHTumblrMenuViewHorizontalMargin 10
#define CHTumblrMenuViewRriseAnimationID @"CHTumblrMenuViewRriseAnimationID"
#define CHTumblrMenuViewDismissAnimationID @"CHTumblrMenuViewDismissAnimationID"
#define CHTumblrMenuViewAnimationTime 0.36
#define CHTumblrMenuViewAnimationInterval (CHTumblrMenuViewAnimationTime / 5)

typedef CGFloat (^EasingFunction)(CGFloat, CGFloat, CGFloat, CGFloat);

@interface PGTumblrMenuItem : UIControl

@property(nonatomic, copy)PGTumblrMenuItemSelectedBlock selectedBlock;

- (instancetype)initWithTitle:(NSString*)title
                      andIcon:(NSString*)iconName
           andHeightLightIcon:(NSString*)hgightIcon
             andSelectedBlock:(PGTumblrMenuItemSelectedBlock)selectBlock;

@end

@implementation PGTumblrMenuItem{
    UIImageView *_iconImageView;
}

-(instancetype)initWithTitle:(NSString *)title
                     andIcon:(NSString *)iconName
          andHeightLightIcon:(NSString *)hgightIcon
            andSelectedBlock:(PGTumblrMenuItemSelectedBlock)selectBlock{
    self = [super init];
    if (self) {
        _iconImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:iconName] highlightedImage:[UIImage imageNamed:hgightIcon]];
        [self addSubview:_iconImageView];
        
        _selectedBlock = selectBlock;
    }
    return self;
}

@end

/////////////////////////////////////////

@interface PGTumblrMenuView ()
@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) CGFloat menuHeight;

@property (nonatomic, assign) CGFloat itemSpacing;

/**
 Duration of the opening/closing animation.
 */
@property (nonatomic, assign) CGFloat animationDuration;

@end

@implementation PGTumblrMenuView{
    NSMutableArray *_Items;
    UIImageView *_backgroundView;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _backgroundView = [[UIImageView alloc]initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.image = [[UIImage imageNamed:@"modal_background"]stretchableImageWithLeftCapWidth:2 topCapHeight:5];
        
        [self addSubview:_backgroundView];
        self.backgroundColor = [UIColor clearColor];
        
        _Items = [NSMutableArray array];
        
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        ges.delegate = self;
        [self addGestureRecognizer:ges];
    }
    
    return self;
}

#pragma mark -
#pragma mark - public method

-(void)addMenuItemWithTitle:(NSString *)title
                    andIcon:(NSString *)iconName
         andHeightLightIcon:(NSString *)hgightIcon
           andSelectedBlock:(PGTumblrMenuItemSelectedBlock)selectBlock{

    PGTumblrMenuItem *pItem = [[PGTumblrMenuItem alloc]initWithTitle:title andIcon:iconName andHeightLightIcon:hgightIcon andSelectedBlock:selectBlock];
    [pItem addTarget:self action:@selector(menuItemTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:pItem];
    
    [_Items addObject:pItem];
}

-(void)show{
    
    self.menuHeight = 60;
    self.animationDuration = 1.3;
//
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topViewController = appRootVC;
    
    while (topViewController.presentedViewController != nil)
    {
        topViewController = topViewController.presentedViewController;
    }
    
//    if ([topViewController.view viewWithTag:CHTumblrMenuViewTag]) {
//        [[topViewController.view viewWithTag:CHTumblrMenuViewTag] removeFromSuperview];
//    }
//
    self.frame = topViewController.view.bounds;
    [topViewController.view addSubview:self];
    
//    [self startRiseAnimation];
    for (UIView *item in _Items) {
        [self performSelector:@selector(showItem:) withObject:item afterDelay:0.08 * [_Items indexOfObject:item]];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_Items enumerateObjectsUsingBlock:^(UIView *item, NSUInteger idx, BOOL *stop) {


        CGRect frame =  [self frameForItemAtIndex:idx];
//        [item setCenter:CGPointMake((idx * 50) + (idx * 10) + (50 / 2), 50 / 2)];
        item.frame = frame;
        item.layer.opacity = 0;

    }];
    


}

#pragma mark -
#pragma mark - Action

-(void)menuItemTapped:(PGTumblrMenuItem*)itemSender{
    NSLog(@"select");
}

- (void)dismiss:(id)sender
{
    for (UIView *item in _Items) {
        [self performSelector:@selector(hideItem:) withObject:item afterDelay:0.08 * [_Items indexOfObject:item]];
    }

    double delayInSeconds = CHTumblrMenuViewAnimationTime  + CHTumblrMenuViewAnimationInterval * (_Items.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
}


#pragma mark -
#pragma mark - private method

- (void)showItem:(UIView *)item {
    [NSObject cancelPreviousPerformRequestsWithTarget:item.layer];
    item.layer.opacity = 1.0f;
    
    CGPoint position = item.layer.position;
    
   
        position.y +=  -self.menuHeight;
        
        [self animateLayer:item.layer
               withKeyPath:@"position.y"
                        to:position.y];
   
    
    item.layer.position = position;
}

- (void)hideItem:(UIView *)item {
    CGPoint position = item.layer.position;
    
   
        position.y +=  self.menuHeight;
        
        [self animateLayer:item.layer
               withKeyPath:@"position.y"
                        to:position.y];
    
    
    item.layer.position = position;
    
    [item.layer performSelector:@selector(setOpacity:) withObject:[NSNumber numberWithFloat:0.0f] afterDelay:0.5];
}

- (void)animateLayer:(CALayer *)layer
         withKeyPath:(NSString *)keyPath
                  to:(CGFloat)endValue {
    CGFloat startValue = [[layer valueForKeyPath:keyPath] floatValue];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = self.animationDuration;
    
    CGFloat steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    CGFloat delta = endValue - startValue;
    EasingFunction function = easeOutElastic;
    
    for (CGFloat t = 0; t < steps; t++) {
        [values addObject:@(function(animation.duration * (t / steps), startValue, delta, animation.duration))];
    }
    
    animation.values = values;
    [layer addAnimation:animation forKey:nil];
}

static EasingFunction easeOutElastic = ^CGFloat(CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat amplitude = 5;
    CGFloat period = 0.6;
    CGFloat s = 0;
    if (t == 0) {
        return b;
    }
    else if ((t /= d) == 1) {
        return b + c;
    }
    
    if (!period) {
        period = d * .3;
    }
    
    if (amplitude < abs(c)) {
        amplitude = c;
        s = period / 4;
    }
    else {
        s = period / (2 * M_PI) * sin(c / amplitude);
    }
    
    return (amplitude * pow(2, -10 * t) * sin((t * d - s) * (2 * M_PI) / period) + c + b);
};

//- (void)startRiseAnimation{
//    
//    NSUInteger columnCount = kColumnCount;
//    NSUInteger rowCount = _Items.count / columnCount + (_Items.count % columnCount >0 ? 1:0);
//    
//    NSUInteger itemCount = _Items.count;
//    for (NSUInteger i = 0 ; i < itemCount; i ++) {
//        PGTumblrMenuItem *item = _Items[i];
////        item.alpha = 0;
//        
//        CGRect frame = [self frameForItemAtIndex:i];
//        
//        NSUInteger rowIndex = [self gotRowIndex:i];
//        NSUInteger columnIndex = [self gotColumnIndex:i];
//        
//        CGPoint fromPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y +  (rowCount - rowIndex + 2)*200 + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
//        
//        CGPoint toPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
//        
//        double delayInSeconds = rowIndex * columnCount * CHTumblrMenuViewAnimationInterval;
//        if (!columnIndex) {
//            delayInSeconds += CHTumblrMenuViewAnimationInterval;
//        }
//        else if(columnIndex == 2) {
//            delayInSeconds += CHTumblrMenuViewAnimationInterval * 2;
//        }
//        
//        CABasicAnimation *positionAnimation;
//        
//        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
//        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
//        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
//        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
//        positionAnimation.duration = CHTumblrMenuViewAnimationTime;
//        positionAnimation.beginTime = [item.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
//        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:i] forKey:CHTumblrMenuViewRriseAnimationID];
//        positionAnimation.delegate = self;
//        
//        [item.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
//        
//    }
//}
//
//- (void)dropAnimation
//{
//    NSUInteger columnCount = 3;
//    for (NSUInteger index = 0; index < _Items.count; index++) {
//        PGTumblrMenuItem *button = _Items[index];
//        CGRect frame = [self frameForItemAtIndex:index];
//        NSUInteger rowIndex = index / columnCount;
//        NSUInteger columnIndex = index % columnCount;
//        
//        CGPoint toPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
//        
//        CGPoint fromPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
//        
//        double delayInSeconds = rowIndex * columnCount * CHTumblrMenuViewAnimationInterval;
//        if (!columnIndex) {
//            delayInSeconds += CHTumblrMenuViewAnimationInterval;
//        }
//        else if(columnIndex == 2) {
//            delayInSeconds += CHTumblrMenuViewAnimationInterval * 2;
//        }
//        CABasicAnimation *positionAnimation;
//        
//        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
//        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
//        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
//        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.5f :1.0f :1.0f];
//        positionAnimation.duration = CHTumblrMenuViewAnimationTime;
//        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
//        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:CHTumblrMenuViewDismissAnimationID];
//        positionAnimation.delegate = self;
//        
//        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
//        
//        
//        
//    }
//    
//}
//
- (CGRect)frameForItemAtIndex:(NSUInteger)index{
    
    NSUInteger rowIndex = [self gotRowIndex:index];
    NSUInteger columnIndex = [self gotColumnIndex:index];
    
    NSUInteger columnCount = kColumnCount;
    NSUInteger rowCount = _Items.count / columnCount + (_Items.count % columnCount >0 ? 1:0);
    
    CGFloat itemHeight = (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * CHTumblrMenuViewHorizontalMargin:0);
    CGFloat offsetY = (self.bounds.size.height - itemHeight) ;
    CGFloat verticalPadding = (self.bounds.size.width - CHTumblrMenuViewHorizontalMargin * 2 - CHTumblrMenuViewImageHeight * 3) / 2.0;
    
    CGFloat offsetX = CHTumblrMenuViewHorizontalMargin;
    offsetX += (CHTumblrMenuViewImageHeight+ verticalPadding) * columnIndex;
    
    offsetY += (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight + CHTumblrMenuViewVerticalPadding) * rowIndex;

    
    return CGRectMake(offsetX, offsetY, CHTumblrMenuViewImageHeight, (CHTumblrMenuViewImageHeight+CHTumblrMenuViewTitleHeight));
}

- (NSUInteger)gotColumnIndex:(NSUInteger)index{
    
    return   index % kColumnCount;
}

- (NSUInteger)gotRowIndex:(NSUInteger)index{
    
    return index/ kColumnCount ;
}
//
//- (void)animationDidStart:(CAAnimation *)anim
//{
//    NSUInteger columnCount = 3;
//    if([anim valueForKey:CHTumblrMenuViewRriseAnimationID]) {
//        NSUInteger index = [[anim valueForKey:CHTumblrMenuViewRriseAnimationID] unsignedIntegerValue];
//        UIView *view = _Items[index];
//        CGRect frame = [self frameForItemAtIndex:index];
//        CGPoint toPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
//        CGFloat toAlpha = 1.0;
//        
//        view.layer.position = toPosition;
//        view.layer.opacity = toAlpha;
//        
//    }
//    else if([anim valueForKey:CHTumblrMenuViewDismissAnimationID]) {
//        NSUInteger index = [[anim valueForKey:CHTumblrMenuViewDismissAnimationID] unsignedIntegerValue];
//        NSUInteger rowIndex = index / columnCount;
//        
//        UIView *view = _Items[index];
//        CGRect frame = [self frameForItemAtIndex:index];
//        CGPoint toPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y -  (rowIndex + 2)*200 + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
//        
//        view.layer.position = toPosition;
//    }
//}



@end
