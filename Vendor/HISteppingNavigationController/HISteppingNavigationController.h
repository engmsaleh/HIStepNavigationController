//
//  HISteppingNavigationController.h
//  HIStepNavigationController
//
//  Created by k-sakata on 9/2/12.
//  Copyright (c) 2012 http://www.huin-lab.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 * @protocol HISteppingNavigationControllerDataSource
 * @discussion ViewController managed by HISteppingNavigationController must conform this protocol.
 */
@protocol HISteppingNavigationControllerDataSource
@required
- (CGFloat)positionOfIndicator;
@end

@interface HISteppingNavigationController : UIViewController

@property (strong, nonatomic) UINavigationBar *navigationBar;

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)stepForwardViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)stepBackwardViewControllerAnimated:(BOOL)animated;

@end

@interface UIViewController(StepNavigation)
- (HISteppingNavigationController *)stepNavigationController;
@end