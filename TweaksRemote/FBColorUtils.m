//
//  FBColorUtils.m
//  TweaksRemote
//
//  Created by Eric Mika on 7/19/14.
//  Copyright (c) 2014 Eric Mika. All rights reserved.
//

#import "FBColorUtils.h"

CGFloat const FBRGBColorComponentMaxValue = 255.0f;
CGFloat const FBAlphaComponentMaxValue = 100.0f;
CGFloat const FBHSBColorComponentMaxValue = 1.0f;

extern BOOL FBIsColorString(NSString *string) {
  return [string hasPrefix:@"#"];
}

extern NSColor* FBColorFromHexString(NSString* hexColor) {
  if (!FBIsColorString(hexColor)) {
    return nil;
  }
  
  NSScanner *scanner = [NSScanner scannerWithString:hexColor];
  [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
  
  unsigned hexNum;
  if (![scanner scanHexInt: &hexNum]) return nil;
  
  int r = (hexNum >> 24) & 0xFF;
  int g = (hexNum >> 16) & 0xFF;
  int b = (hexNum >> 8) & 0xFF;
  int a = (hexNum) & 0xFF;
  
  return [NSColor colorWithRed:r / FBRGBColorComponentMaxValue
                         green:g / FBRGBColorComponentMaxValue
                          blue:b / FBRGBColorComponentMaxValue
                         alpha:a / FBRGBColorComponentMaxValue];
}



extern NSString* FBHexStringFromColor(NSColor* color)
{
  CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
  if (colorSpaceModel != kCGColorSpaceModelRGB && colorSpaceModel != kCGColorSpaceModelMonochrome) {
    return nil;
  }
  const CGFloat *components = CGColorGetComponents(color.CGColor);
  CGFloat red, green, blue, alpha;
  if (colorSpaceModel == kCGColorSpaceModelMonochrome) {
    red = green = blue = components[0];
    alpha = components[1];
  } else {
    red = components[0];
    green = components[1];
    blue = components[2];
    alpha = components[3];
  }
  NSString *hexColorString = [NSString stringWithFormat:@"#%02X%02X%02X%02X",
                              (UInt8)(red * FBRGBColorComponentMaxValue),
                              (UInt8)(green * FBRGBColorComponentMaxValue),
                              (UInt8)(blue * FBRGBColorComponentMaxValue),
                              (UInt8)(alpha * FBRGBColorComponentMaxValue)];
  return hexColorString;
}

