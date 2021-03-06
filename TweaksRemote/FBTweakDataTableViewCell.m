//
//  FBTweakTableViewCell.m
//  TweaksRemote
//
//  Created by Noah Hilt on 7/7/14.
//  Copyright (c) 2014 Noah Hilt. All rights reserved.
//

#import "FBTweakDataTableViewCell.h"
#import "FBColorUtils.h"

@interface FBTweakDataTableViewCell ()

@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSStepper *stepper;
@property (weak) IBOutlet NSButton *checkButton;
@property (weak) IBOutlet NSButton *actionButton;
@property (weak) IBOutlet NSColorWell *colorWell;

@end

@implementation FBTweakDataTableViewCell

- (void)setTweakData:(FBTweakData *)tweakData {
  
  [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
  
  if (_tweakData != tweakData) {
    _tweakData = tweakData;

    self.nameLabel.stringValue = _tweakData.name;
    
    // Hide all controls by default
    self.slider.hidden = YES;
    self.textField.hidden = YES;
    self.stepper.hidden = YES;
    self.checkButton.hidden = YES;
    self.actionButton.hidden = YES;
    self.colorWell.hidden = YES;
    
    // Selectively reveal controls and set view state
    switch (_tweakData.type) {
      case FBTweakDataTypeBoolean:
        self.checkButton.hidden = NO;
        break;

      case FBTweakDataTypeInteger:
        self.textField.hidden = NO;
        self.stepper.hidden = NO;
        self.slider.hidden = NO;

        if (self.tweakData.stepValue) {
          self.stepper.increment = [self.tweakData.stepValue floatValue];
        } else {
          self.stepper.increment = 1.0;
        }

        if (self.tweakData.minimumValue) {
          self.slider.minValue = self.stepper.minValue = [self.tweakData.minimumValue longLongValue];
        } else {
          self.slider.minValue = self.stepper.minValue = [self.tweakData.currentValue longLongValue] / 10.0;
        }

        if (self.tweakData.maximumValue) {
          self.slider.maxValue = self.stepper.maxValue = [self.tweakData.maximumValue longLongValue];
        } else {
          self.slider.maxValue = self.stepper.maxValue = [self.tweakData.currentValue longLongValue] * 10.0;
        }
        break;

      case FBTweakDataTypeReal:
        self.textField.hidden = NO;
        self.stepper.hidden = NO;
        self.slider.hidden = NO;

        if (self.tweakData.minimumValue) {
          self.slider.minValue = self.stepper.minValue = [self.tweakData.minimumValue doubleValue];
        } else {
          self.slider.minValue = self.stepper.minValue = [self.tweakData.currentValue doubleValue] / 10.0;
        }

        if (self.tweakData.maximumValue) {
          self.slider.maxValue = self.stepper.maxValue = [self.tweakData.maximumValue doubleValue];
        } else {
          self.slider.maxValue = self.stepper.maxValue = [self.tweakData.currentValue doubleValue] * 10.0;
        }

        if (self.tweakData.stepValue) {
          self.stepper.increment = [self.tweakData.stepValue floatValue];
        } else {
          self.stepper.increment = fminf(1.0, (self.stepper.maxValue - self.stepper.minValue) / 100.0);
        }
        break;

      case FBTweakDataTypeString:
        self.textField.hidden = NO;

        // Handle color strings
        if (FBIsColorString(self.tweakData.currentValue)) {
          self.colorWell.hidden = NO;
        }
        break;

      case FBTweakDataTypeAction:
        self.actionButton.hidden = NO;
        break;

      case FBTweakDataTypeNone:
      default:
        break;
    }
  }

  [self _updateValue:_tweakData.currentValue primary:YES write:NO];
}

- (IBAction)_switchChanged:(NSButton *)button {
  [self _updateValue:self.checkButton.state == NSOnState ? @(YES) : @(NO) primary:NO write:YES];
}

- (IBAction)_stepperChanged:(NSStepper *)stepper {
  if (self.tweakData.type == FBTweakDataTypeInteger) {
    [self _updateValue:@(stepper.integerValue) primary:NO write:YES];
  } else {
    [self _updateValue:@(stepper.doubleValue) primary:NO write:YES];
  }
}

- (IBAction)_sliderChanged:(NSSlider *)slider {
  if (self.tweakData.type == FBTweakDataTypeInteger) {
    [self _updateValue:@(slider.integerValue) primary:NO write:YES];
  } else {
    [self _updateValue:@(slider.doubleValue) primary:NO write:YES];
  }
}

- (IBAction)_colorChanged:(NSColorWell *)colorWell {
  [self _updateValue:FBHexStringFromColor(colorWell.color) primary:NO write:YES];
}


- (IBAction)_actionPressed:(NSButton *)button {
  if ([self.delegate respondsToSelector:@selector(tweakAction:)]) {
    [self.delegate tweakAction:self.tweakData];
  }
}

- (void)_updateValue:(id)value primary:(BOOL)primary write:(BOOL)write {
  if (write) {
    self.tweakData.currentValue = value;
    if ([self.delegate respondsToSelector:@selector(tweakDidChange:)]) {
      [self.delegate tweakDidChange:self.tweakData];
    }
  }

  switch (self.tweakData.type) {
    case FBTweakDataTypeBoolean:
      if (primary) {
        [self.checkButton setState:[value boolValue] ? NSOnState : NSOffState];
      }
      break;

    case FBTweakDataTypeInteger:
      // if (primary) {
      self.slider.integerValue = self.stepper.integerValue = [value integerValue];
      //}

      [self.textField setStringValue:[value stringValue]];
      break;

    case FBTweakDataTypeReal: {
      // if (primary) {
      self.slider.doubleValue = self.stepper.doubleValue = [value doubleValue];
      //}

      double exp = log10(self.stepper.increment);
      long precision = exp < 0 ? ceilf(fabs(exp)) : 0;

      if (self.tweakData.precisionValue) {
        precision = [[self.tweakData precisionValue] longValue];
      }

      NSString *format = [NSString stringWithFormat:@"%%.%ldf", precision];
      [self.textField setStringValue:[NSString stringWithFormat:format, [value doubleValue]]];
      break;
    }

    case FBTweakDataTypeString:
      //if (primary) {
      self.textField.stringValue = value;
      
        if (FBIsColorString(value)) {
          // update the color well, too
          // this rebroadcasts... but better guard than "primary" flag
          self.colorWell.color = FBColorFromHexString(value);
        }
      //}
      break;

    case FBTweakDataTypeAction:
    case FBTweakDataTypeNone:
    default:
      break;
  }
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidEndEditing:(NSNotification *)notification {
  switch (self.tweakData.type) {
    case FBTweakDataTypeInteger:
      [self _updateValue:@([self.textField integerValue]) primary:NO write:YES];
      break;

    case FBTweakDataTypeReal:
      [self _updateValue:@([self.textField doubleValue]) primary:NO write:YES];
      break;

    case FBTweakDataTypeString: {
      // attempted validation
      // ick, need more structured tweak types
      if (FBIsColorString(self.tweakData.currentValue)) {
        // It's a color, make sure it has a leading hash
        if (!FBIsColorString(self.textField.stringValue)) {
          // ignore and use old value
          self.textField.stringValue = self.tweakData.currentValue;
        }
      }
      else {
        // It's a string, make sure it doesn't have a leading hash
        if (FBIsColorString(self.textField.stringValue)) {
          // ignore and use old value
          self.textField.stringValue = self.tweakData.currentValue;
        }
      }
      
      [self _updateValue:self.textField.stringValue primary:NO write:YES];
    }
      break;

    case FBTweakDataTypeAction:
    case FBTweakDataTypeBoolean:
    case FBTweakDataTypeNone:
    default:
      NSAssert(NO, @"unexpected type");
      break;
  }
}

@end
