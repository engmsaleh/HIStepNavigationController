//
//  HISteppingNavigationController.m
//  HIStepNavigationController
//
//  Created by k-sakata on 9/2/12.
//  Copyright (c) 2012 http://www.huin-lab.com. All rights reserved.
//

#import "HISteppingNavigationController.h"

@interface HISteppingNavigationController ()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIImageView *stepIndicator;
@property (strong, nonatomic) NSMutableArray *viewControllers;

- (void)_confirmProtocolAdoption:(UIViewController *)viewController;
- (CGRect)_stepIndicatorFrame:(CGFloat)xPos;

@end

@implementation UIViewController(StepNavigation)

- (HISteppingNavigationController *)stepNavigationController
{
  UIViewController *superViewController = self.parentViewController;
  if(!(nil == superViewController ||
     [superViewController isKindOfClass:[HISteppingNavigationController class]])){
    superViewController = superViewController.parentViewController;
  }
  return (HISteppingNavigationController *)superViewController;
}

@end

@implementation HISteppingNavigationController

@synthesize navigationBar = _navigationBar;
@synthesize containerView = _containerView;
@synthesize stepIndicator = _stepIndicator;
@synthesize viewControllers = _viewControllers;

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
  NSAssert(rootViewController, @"rootViewController is not allowed nil.");
  
  self = [super init];
  if(self){
    if(nil == _viewControllers){
      _viewControllers = [NSMutableArray array];
    }
    
    [self _confirmProtocolAdoption:rootViewController];
    [self.viewControllers addObject:rootViewController];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  UIImage *navBarBg = [UIImage imageNamed:@"HISNavigationController_Bg"];
  [self.navigationBar setBackgroundImage:navBarBg forBarMetrics:UIBarMetricsDefault];
  [self.view addSubview:self.navigationBar];
  
  UIImage *indicatorImg = [UIImage imageNamed:@"HISNavigationBar_Indicator"];
  self.stepIndicator = [[UIImageView alloc] initWithImage:indicatorImg];
  [self.stepIndicator setFrame:CGRectMake(0, 43, 17, 9)];
  [self.navigationBar addSubview:self.stepIndicator];
  
  self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.0, 320, CGRectGetHeight(self.view.frame)-44.0)];
  self.containerView.backgroundColor = [UIColor redColor];
  [self.view insertSubview:self.containerView belowSubview:self.navigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
  UIViewController<HISteppingNavigationControllerDataSource> *rootVC;
  rootVC = [self.viewControllers objectAtIndex:0];
  self.stepIndicator.frame = [self _stepIndicatorFrame:[rootVC positionOfIndicator]];
  
  [rootVC.view removeFromSuperview];
  [rootVC willMoveToParentViewController:nil];
  [rootVC removeFromParentViewController];
  
  rootVC.view.frame = self.containerView.bounds;
  [self addChildViewController:rootVC];
  
  [rootVC didMoveToParentViewController:self];
  [self.containerView addSubview:rootVC.view];
  
  // remove later
  UIImage *progressBar = [UIImage imageNamed:@"ProgoressBar"];
  UIImageView *progressBarView = [[UIImageView alloc] initWithImage:progressBar];
  progressBarView.frame = CGRectMake(0, 59, 320, 40);
  [self.view insertSubview:progressBarView belowSubview:self.navigationBar];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)stepForwardViewController:(UIViewController<HISteppingNavigationControllerDataSource> *)viewController
                         animated:(BOOL)animated
{
  [self _confirmProtocolAdoption:viewController];
  
//  if(!animated){
//    return;
//  }
  int count = [self.viewControllers count];
  UIViewController *currentViewController = [self.viewControllers objectAtIndex:count-1];
  
  __block CGRect nvcRect = self.containerView.bounds;
  nvcRect.origin.x = 320.0;
  viewController.view.frame = nvcRect;
  
  [viewController.view removeFromSuperview];
  [viewController willMoveToParentViewController:nil];
  [viewController removeFromParentViewController];
  [self addChildViewController:viewController];
  [self.viewControllers addObject:viewController];
  [viewController didMoveToParentViewController:self];
  
  [self.containerView addSubview:viewController.view];
  
  [UIView animateWithDuration:0.4
                   animations:^(void){
                     self.stepIndicator.frame = [self _stepIndicatorFrame:[viewController positionOfIndicator]];
                     nvcRect.origin.x = 0.0;
                     viewController.view.frame = nvcRect;
                     
                     CGRect cvcRect = currentViewController.view.frame;
                     cvcRect.origin.x = -320.0;
                     currentViewController.view.frame = cvcRect;
                   }
                   completion:^(BOOL finished){
                     [currentViewController.view removeFromSuperview];
                   }];
}

- (UIViewController *)stepBackwardViewControllerAnimated:(BOOL)animated
{
  if([self.viewControllers count]<2){
    return nil;
  }
  
  int count = [self.viewControllers count];
  UIViewController *currentViewController = [self.viewControllers objectAtIndex:count-1];
  
  UIViewController<HISteppingNavigationControllerDataSource> *previousViewController;
  previousViewController = [self.viewControllers objectAtIndex:count-2];
  __block CGRect pvcRect = previousViewController.view.frame;
  pvcRect.origin.x = -320.0;
  previousViewController.view.frame = pvcRect;
  [self.containerView insertSubview:previousViewController.view belowSubview:currentViewController.view];
  
  [UIView animateWithDuration:0.4
                   animations:^(void){
                     self.stepIndicator.frame = [self _stepIndicatorFrame:[previousViewController positionOfIndicator]];
                     
                     CGRect cvcRect = currentViewController.view.frame;
                     cvcRect.origin.x = 320.0;
                     currentViewController.view.frame = cvcRect;
                     
                     pvcRect.origin.x = 0.0;
                     previousViewController.view.frame = pvcRect;
                   }
                   completion:^(BOOL finished){
                     [currentViewController.view removeFromSuperview];
                     [currentViewController willMoveToParentViewController:self];
                     [currentViewController removeFromParentViewController];
                     [self.viewControllers removeObject:currentViewController];
                     [currentViewController didMoveToParentViewController:nil];
                   }];
  
  return currentViewController;
}

- (void)_confirmProtocolAdoption:(UIViewController *)viewController
{
  if(![viewController conformsToProtocol:@protocol(HISteppingNavigationControllerDataSource)]){
    NSAssert(NO, @"ViewController managed by HISteppingNavigationController must conform this protocol.");
  }
}

- (CGRect)_stepIndicatorFrame:(CGFloat)xPos
{
  CGRect indicatorFrame = self.stepIndicator.frame;
  indicatorFrame.origin.x = xPos-(indicatorFrame.size.width/2);
  
  return indicatorFrame;
}

@end
