//
//  HISFirstStepViewController.m
//  HIStepNavigationController
//
//  Created by k-sakata on 9/2/12.
//  Copyright (c) 2012 http://www.huin-lab.com. All rights reserved.
//

#import "HISFirstStepViewController.h"

@interface HISFirstStepViewController ()

- (IBAction)_nextButtonDidPushed:(id)sender;

@end

@implementation HISFirstStepViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
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

#pragma mark - IBAction

- (IBAction)_nextButtonDidPushed:(id)sender
{
  UIViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondStepView"];
  [self.stepNavigationController stepForwardViewController:nextVC animated:YES];
}

#pragma mark - HISteppingNavigationControllerDataSource

- (CGFloat)positionOfIndicator
{
  return 63.0;
}

@end
