//
//  FBColorUtils.h
//  TweaksRemote
//
//  Created by Eric Mika on 7/19/14.
//  Copyright (c) 2014 Eric Mika. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CGFloat const FBRGBColorComponentMaxValue;
extern CGFloat const FBAlphaComponentMaxValue;
extern CGFloat const FBHSBColorComponentMaxValue;

extern BOOL FBIsColorString(NSString *string);

/**
 *  Converts hex string to the NSColor representation.
 *
 *  @param color The color value.
 *
 *  @return The hex string color value.
 */
extern NSString* FBHexStringFromColor(NSColor* color);

/**
 *  Converts NSColor value to the hex string.
 *
 *  @param hexString The hex string color value.
 *
 *  @return The color value.
 */
extern NSColor* FBColorFromHexString(NSString* hexString);

