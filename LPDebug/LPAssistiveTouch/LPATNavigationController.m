//
//  LPATNavigationController.m
//  LPAssistiveTouchDemo
//
//  Created by XuYafei on 16/1/8.
//  Copyright © 2016年 loopeer. All rights reserved.
//

#import "LPATNavigationController.h"

@interface LPATNavigationController ()

@end

@implementation LPATNavigationController {
    NSMutableArray<LPATPosition *> *_pushPosition;
}

#pragma mark - Initialization

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithRootViewController:[LPATViewController new]];
}

- (instancetype)initWithRootViewController:(LPATViewController *)viewController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewControllers = [NSMutableArray arrayWithObject:viewController];
        viewController.navgationController = self;
        _pushPosition = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%@%s", NSStringFromClass([self class]), __func__);
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    _shrinkPoint = CGPointMake(CGRectGetWidth(self.view.frame) - imageViewWidth / 2,
                               CGRectGetMidY(self.view.frame));
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewWidth)];
    _contentView.center = _shrinkPoint;
    _contentView.backgroundColor = [UIColor grayColor];
    _contentView.layer.cornerRadius = 14;
    [self.view addSubview:_contentView];
    
    _contentItem = [LPATItemView itemWithType:LPATItemViewTypeSystem];
    _contentItem.center = _shrinkPoint;
    [self.view addSubview:_contentItem];
}

- (void)setShrinkPoint:(CGPoint)shrinkPoint {
    if (!_show) {
        _shrinkPoint = shrinkPoint;
        _contentView.center = shrinkPoint;
        _contentItem.center = shrinkPoint;
    }
}

#pragma mark - Animition

- (void)spread {
    _show = YES;
    NSUInteger count = _viewControllers.firstObject.items.count;
    for (int i = 0; i < count; i++) {
        LPATItemView *item = _viewControllers.firstObject.items[i];
        item.alpha = 0;
        item.center = _shrinkPoint;
        [self.view addSubview:item];
        [UIView animateWithDuration:duration animations:^{
            item.center = [LPATPosition positionWithCount:count index:i].center;
            item.alpha = 1;
        }];
    }
    
    [UIView animateWithDuration:duration animations:^{
        _contentView.frame = [LPATPosition contentViewFrame];
        _contentItem.center = [LPATPosition positionWithCount:count index:count - 1].center;
        _contentItem.alpha = 0;
    }];
}

- (void)shrink {
    _show = NO;
    for (LPATItemView *item in _viewControllers.lastObject.items) {
        [UIView animateWithDuration:duration animations:^{
            item.center = _shrinkPoint;
            item.alpha = 0;
        }];
    }
    [UIView animateWithDuration:duration animations:^{
        _viewControllers.lastObject.backItem.center = _shrinkPoint;
        _viewControllers.lastObject.backItem.alpha = 0;
    }];
    
    [UIView animateWithDuration:duration animations:^{
        _contentView.frame = CGRectMake(0, 0, imageViewWidth, imageViewWidth);
        _contentView.center = _shrinkPoint;
        _contentItem.alpha = 1;
        _contentItem.center = _shrinkPoint;
    } completion:^(BOOL finished) {
        for (LPATViewController *viewController in _viewControllers) {
            [viewController.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [viewController.backItem removeFromSuperview];
        }
        _viewControllers = [NSMutableArray arrayWithObject:_viewControllers.firstObject];
    }];
}

- (void)pushViewController:(LPATViewController *)viewController atPisition:(LPATPosition *)position {
    LPATViewController *oldViewController = _viewControllers.lastObject;
    for (LPATItemView *item in oldViewController.items) {
        [UIView animateWithDuration:duration animations:^{
            item.alpha = 0;
        }];
    }
    [UIView animateWithDuration:duration animations:^{
        oldViewController.backItem.alpha = 0;
    }];
    
    NSUInteger count = viewController.items.count;
    for (int i = 0; i < count; i++) {
        LPATItemView *item = viewController.items[i];
        item.alpha = 0;
        item.center = position.center;
        [self.view addSubview:item];
        [UIView animateWithDuration:duration animations:^{
            item.center = [LPATPosition positionWithCount:count index:i].center;
            item.alpha = 1;
        }];
    }
    viewController.backItem.alpha = 0;
    viewController.backItem.center = position.center;
    [self.view addSubview:viewController.backItem];
    [UIView animateWithDuration:duration animations:^{
        viewController.backItem.center = self.view.center;
        viewController.backItem.alpha = 1;
    }];
    
    viewController.navgationController = self;
    [_viewControllers addObject:viewController];
    [_pushPosition addObject:position];
}

- (void)popViewController {
    if (_pushPosition.count > 0) {
        LPATPosition *position = _pushPosition.lastObject;
        for (LPATItemView *item in _viewControllers.lastObject.items) {
            [UIView animateWithDuration:duration animations:^{
                item.center = position.center;
                item.alpha = 0;
            }];
        }
        [UIView animateWithDuration:duration animations:^{
            _viewControllers.lastObject.backItem.center = position.center;
            _viewControllers.lastObject.backItem.alpha = 0;
        } completion:^(BOOL finished) {
            [_viewControllers.lastObject.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [_viewControllers.lastObject.backItem removeFromSuperview];
            [_viewControllers removeLastObject];
            for (LPATItemView *item in _viewControllers.lastObject.items) {
                [UIView animateWithDuration:duration animations:^{
                    item.alpha = 1;
                }];
            }
        }];
    }
}

@end
