//
//  HIStepProgressBar.h
//  HIStepProgressBar
//
//  Created by koichisakata on 9/2/12.
//  Copyright (c) 2012 http://www.huin-lab.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

enum HISCurrentStep {
  HISCurrentStepOne = 0,
  HISCurrentStepTwo = 1,
  HISCurrentStepThree = 2
};

typedef enum HISCurrentStep HISCurrentStep;

@interface HIStepProgressBarView : UIView

@property (nonatomic, readonly) HISCurrentStep currentStep;
@property (strong, nonatomic) UIColor *defaultLabelColor;
@property (strong, nonatomic) UIColor *currentLabelColor;

- (void)progressBarToStep:(HISCurrentStep)step completion:(void (^)(void))handler;

@end
