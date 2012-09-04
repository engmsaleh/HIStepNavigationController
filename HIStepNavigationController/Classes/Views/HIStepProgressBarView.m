//
//  HIStepProgressBar.m
//  HIStepProgressBar
//
//  Created by koichisakata on 9/2/12.
//  Copyright (c) 2012 http://www.huin-lab.com. All rights reserved.
//

#import "HIStepProgressBarView.h"

@interface HIStepProgressBarView()

@property (strong, nonatomic) UILabel *stepOneLabel;
@property (strong, nonatomic) UILabel *stepTwoLabel;
@property (strong, nonatomic) UILabel *stepThreeLabel;

@property (strong, nonatomic) CAShapeLayer *guageLayer;
@property (strong, nonatomic) CAShapeLayer *guageMaskLayer;
@property (strong, nonatomic) CAShapeLayer *currentStepDot;

- (void)_setupStepButtons;
- (void)_setupLayers;

- (CGPathRef)_guagePathInRect:(CGRect)rect;
- (CGPathRef)_guageMaskPathInRect:(CGRect)rect progress:(CGFloat)progress;

- (void)_updateStepLabelAndDot;
- (void)_switchCurrentStepLabel:(HISCurrentStep)step;
- (CGFloat)_progressForStep:(HISCurrentStep)step;
- (CGRect)_rectFotCurrentStepDot:(HISCurrentStep)step;

@end

@implementation HIStepProgressBarView

@synthesize currentStep = _currentStep;
@synthesize defaultLabelColor = _defaultLabelColor;
@synthesize currentLabelColor = _currentLabelColor;
@synthesize guageLayer = _guageLayer;
@synthesize guageMaskLayer = _guageMaskLayer;
@synthesize currentStepDot = _currentStepDot;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.backgroundColor  = [UIColor clearColor];
    _currentStep = HISCurrentStepOne;
    _defaultLabelColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    _currentLabelColor = [UIColor colorWithRed:220.0/255.0 green:181.0/255.0 blue:0.0 alpha:1.0];
    
    [self _setupStepButtons];
    [self _setupLayers];
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
}

- (void)_setupStepButtons
{
  UIColor *bgColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
  UIColor *hgColor = [UIColor whiteColor];
  CGSize shadowOffset = CGSizeMake(0.0, 1.0);
  UIFont *textFont = [UIFont boldSystemFontOfSize:12.0];
  
  // Draw Label;
  self.stepOneLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.5, 12.5, 40, 20)];
  self.stepOneLabel.backgroundColor = bgColor;
  self.stepOneLabel.textColor = self.currentLabelColor;
  self.stepOneLabel.font = textFont;
  self.stepOneLabel.text = @"Step1";
  self.stepOneLabel.shadowColor = hgColor;
  self.stepOneLabel.shadowOffset = shadowOffset;
  [self.stepOneLabel sizeToFit];
  [self addSubview:self.stepOneLabel];
  
  self.stepTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(142, 12.5, 40, 20)];
  self.stepTwoLabel.backgroundColor = bgColor;
  self.stepTwoLabel.textColor = self.defaultLabelColor;
  self.stepTwoLabel.font = textFont;
  self.stepTwoLabel.text = @"Step2";
  self.stepTwoLabel.shadowColor = hgColor;
  self.stepTwoLabel.shadowOffset = shadowOffset;
  [self.stepTwoLabel sizeToFit];
  [self addSubview:self.stepTwoLabel];
  
  self.stepThreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 12.5, 40, 20)];
  self.stepThreeLabel.backgroundColor = bgColor;
  self.stepThreeLabel.textColor = self.defaultLabelColor;
  self.stepThreeLabel.font = textFont;
  self.stepThreeLabel.text = @"Step3";
  self.stepThreeLabel.shadowColor = hgColor;
  self.stepThreeLabel.shadowOffset = shadowOffset;
  [self.stepThreeLabel sizeToFit];
  [self addSubview:self.stepThreeLabel];
  
  [self _switchCurrentStepLabel:_currentStep];
}

- (void)_setupLayers
{
  CGRect rect = self.frame;
  CGPathRef path = [self _guagePathInRect:CGRectZero];
 
  // Base
  CAShapeLayer *baseLayer = [CAShapeLayer layer];
  baseLayer.path = path;
  baseLayer.fillColor = [[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:232.0/255.0 alpha:1.0] CGColor];
  
  // Highlight Layer
  CAShapeLayer *hgLayer = [CAShapeLayer layer];
  hgLayer.path = path;
  hgLayer.fillColor = [[UIColor whiteColor] CGColor];
  CGRect hgLayerFrame = hgLayer.frame;
  hgLayerFrame.origin.y += 1.0;
  hgLayer.frame = hgLayerFrame;

  // Guage
  self.guageLayer = [CAShapeLayer layer];
  self.guageLayer.frame = CGRectZero;
  self.guageLayer.fillColor = [[UIColor colorWithRed:255.0/255.0 green:247.0/255.0 blue:122.0/255.0 alpha:1.0] CGColor];
  self.guageLayer.path = path;
  
  // Guage mask
  CGPathRef maskPath = [self _guageMaskPathInRect:CGRectZero progress:[self _progressForStep:_currentStep]];
  self.guageMaskLayer = [CAShapeLayer layer];
  self.guageMaskLayer.frame = CGRectMake(15.0, 29.0, CGRectGetWidth(rect), CGRectGetHeight(rect));
  self.guageMaskLayer.fillColor = [[UIColor blackColor]  CGColor];
  self.guageMaskLayer.path = maskPath;
  
  self.guageLayer.mask = self.guageMaskLayer;
  
  // Dot for Current Step
  self.currentStepDot = [CAShapeLayer layer];
  CGMutablePathRef dotPath = CGPathCreateMutable();
  CGPathAddEllipseInRect(dotPath, NULL, CGRectMake(0, 0, 5.0, 5.0));
  self.currentStepDot.path = dotPath;
  self.currentStepDot.fillColor = [[UIColor colorWithRed:232.0/255.0 green:207.0/255.0 blue:0.0 alpha:1.0] CGColor];
  self.currentStepDot.anchorPoint = CGPointMake(0.0, 0.0);
  self.currentStepDot.frame = [self _rectFotCurrentStepDot:_currentStep];
  
  [self.layer addSublayer:hgLayer];
  [self.layer addSublayer:baseLayer];
  [self.layer addSublayer:self.guageLayer];
  [self.layer addSublayer:self.currentStepDot];
  
  CGPathRelease(path);
  CGPathRelease(maskPath);
  CGPathRelease(dotPath);
}

- (CGPathRef)_guagePathInRect:(CGRect)rect
{
  CGFloat oX = rect.origin.x;
  CGFloat oY = rect.origin.y;
  
  // Draw Path
  // -------------------------------------------------------------------------
  // top-left     : ( 17.5, 33.0) : top-right    : (302.5, 33.0)
  // bottom-left  : ( 17.5, 33.0) : bottom-right : (302.5, 39.0)
  CGMutablePathRef guagePath = CGPathCreateMutable();
  CGPathMoveToPoint(guagePath, NULL, oX+17.5, oY+33.0); // top-left
  CGPathAddLineToPoint(guagePath, NULL, oX+302.5, oY+33.0); // top-right
  CGPathAddArcToPoint(guagePath, NULL, oX+305.0, oY+33.0, oX+305, oY+36.0, 3.0);
  CGPathAddArcToPoint(guagePath, NULL, oX+305.0, oY+39.0, oX+302.5, oY+39.0, 3.0);
  CGPathAddLineToPoint(guagePath, NULL, oX+302.5, oY+39.0); // bottom-right
  CGPathAddLineToPoint(guagePath, NULL, oX+17.5, oY+39.0);  // bottom-left
  CGPathAddArcToPoint(guagePath, NULL, oX+15.0, oY+39.0, oX+15.0, oY+36.0, 3.0);
  CGPathAddArcToPoint(guagePath, NULL, oX+15.0, oY+33.0, oX+17.5, oY+33.0, 3.0);
  CGPathCloseSubpath(guagePath);
  
  // add Step Circles
  CGPathAddEllipseInRect(guagePath, NULL, CGRectMake(57.5, 29.5, 12.5, 12.5));
  CGPathAddEllipseInRect(guagePath, NULL, CGRectMake(153.5, 29.5, 12.5, 12.5));
  CGPathAddEllipseInRect(guagePath, NULL, CGRectMake(250.0, 29.5, 12.5, 12.5));
  
  return guagePath;
}

- (CGPathRef)_guageMaskPathInRect:(CGRect)rect progress:(CGFloat)progress
{
  CGFloat radius = 6.25;
  CGFloat oX = rect.origin.x;
  CGFloat oY = rect.origin.y;
  
  CGMutablePathRef maskPath = CGPathCreateMutable();
  CGPathMoveToPoint(maskPath,    NULL, oX, oY);
  CGPathAddLineToPoint(maskPath, NULL, oX+progress-radius, oY);
  CGPathAddArcToPoint(maskPath,  NULL, oX+progress, oY, oX+progress, oY+6.75, radius);
  CGPathAddArcToPoint(maskPath,  NULL, oX+progress, oY+13.5, oX+progress-radius, oY+13.5, radius);
  CGPathAddLineToPoint(maskPath, NULL, oX+progress, oY+13.5);
  CGPathAddLineToPoint(maskPath, NULL, oX, oY+13.5);
  CGPathAddLineToPoint(maskPath, NULL, oX, oY);
  CGPathCloseSubpath(maskPath);

  return maskPath;
}

- (void)progressBarToStep:(HISCurrentStep)step completion:(void (^)(void))handler
{
  NSLog(@"%s %i", __FUNCTION__, step);
  
  [CATransaction begin];
  [CATransaction setAnimationDuration:0.5];
  [CATransaction setCompletionBlock:^(void){
    _currentStep = step;
    [self performSelector:@selector(_updateStepLabelAndDot) withObject:nil afterDelay:0.2];
  }];
  CGPathRef newMaskPath = [self _guageMaskPathInRect:self.frame progress:[self _progressForStep:step]];
  CGPathRef oldMaskPath = self.guageMaskLayer.path;
  self.guageMaskLayer.path = newMaskPath;

  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
  animation.fromValue = (__bridge id)oldMaskPath;
  animation.toValue = (__bridge id)newMaskPath;
  [self.guageMaskLayer addAnimation:animation forKey:nil];
  [CATransaction commit];
  
  CGPathRelease(newMaskPath);

  if(nil!=handler){
    handler();
  }
}

- (void)_updateStepLabelAndDot
{
  [CATransaction begin];
  [CATransaction setAnimationDuration:0.0];
  self.currentStepDot.frame = [self _rectFotCurrentStepDot:_currentStep];
  [CATransaction commit];
  [self _switchCurrentStepLabel:_currentStep];
}

- (void)_switchCurrentStepLabel:(HISCurrentStep)step
{
  switch (step) {
    case HISCurrentStepOne:
      self.stepOneLabel.textColor = self.currentLabelColor;
      self.stepTwoLabel.textColor = self.defaultLabelColor;
      self.stepThreeLabel.textColor = self.defaultLabelColor;
      break;
    case HISCurrentStepTwo:
      self.stepOneLabel.textColor = self.defaultLabelColor;
      self.stepTwoLabel.textColor = self.currentLabelColor;
      self.stepThreeLabel.textColor = self.defaultLabelColor;
      break;
    case HISCurrentStepThree:
      self.stepOneLabel.textColor = self.defaultLabelColor;
      self.stepTwoLabel.textColor = self.defaultLabelColor;
      self.stepThreeLabel.textColor = self.currentLabelColor;
      break;
    default:
      break;
  }
}

// x position for every step
// -------------------------
// 1 : 97.25, 2 : 207.75, 3 : 305.5
// max width : 291.0
- (CGFloat)_progressForStep:(HISCurrentStep)step
{
  switch (step) {
    case HISCurrentStepOne:
      return 97.25;
      break;
    case HISCurrentStepTwo:
      return 193.25;
      break;
    case HISCurrentStepThree:
      return 291.0;
      break;
    default:
      return 0.0;
      break;
  }
}

- (CGRect)_rectFotCurrentStepDot:(HISCurrentStep)step
{
  switch (step) {
    case HISCurrentStepOne:
      return CGRectMake(61, 33.5, 5, 5);
      break;
    case HISCurrentStepTwo:
      return CGRectMake(157, 33.5, 5, 5);
      break;
    case HISCurrentStepThree:
      return CGRectMake(253.75, 33.5, 5, 5);
      break;
    default:
      break;
  }
  
  return CGRectZero;
}

@end
