//
//  UIColor+Util.m
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "UIColor+Util.h"


// Slightly modified from: http://www.drobnik.com/touch/2009/10/manipulating-uicolors/

@implementation UIColor (Util)

- (UIColor *)colorDarkenedByPercent:(CGFloat)percent
{
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self CGColor]);
	CGFloat newComponents[4];
    
	int numComponents = CGColorGetNumberOfComponents([self CGColor]);
    
	switch (numComponents) 
	{
		case 2:
		{
			//grayscale
			newComponents[0] = oldComponents[0]*(1-percent);
			newComponents[1] = oldComponents[0]*(1-percent);
			newComponents[2] = oldComponents[0]*(1-percent);
			newComponents[3] = oldComponents[1];
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0]*(1-percent);
			newComponents[1] = oldComponents[1]*(1-percent);
			newComponents[2] = oldComponents[2]*(1-percent);
			newComponents[3] = oldComponents[3];
			break;
		}
	}
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
	return retColor;
}
//method found at: http://github.com/jonasschnelli/UIColor-i7HexColor
+ (UIColor *)colorWithHexString:(NSString *)hexString {
	
	/* convert the string into a int */
	unsigned int colorValue;
	NSString *hexStringCleared = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
	if(hexStringCleared.length == 3) {
		/* short color form */
		/* im lazy, maybe you have a better idea to convert from #fff to #ffffff */
		hexStringCleared = [NSString stringWithFormat:@"%@%@%@%@%@%@", [hexStringCleared substringWithRange:NSMakeRange(0, 1)],[hexStringCleared substringWithRange:NSMakeRange(0, 1)],
							[hexStringCleared substringWithRange:NSMakeRange(1, 1)],[hexStringCleared substringWithRange:NSMakeRange(1, 1)],
							[hexStringCleared substringWithRange:NSMakeRange(2, 1)],[hexStringCleared substringWithRange:NSMakeRange(2, 1)]];
	}

	[[NSScanner scannerWithString:hexStringCleared] scanHexInt:&colorValue];
	
	/* now build the UIColor with standard allocators */
	return [UIColor colorWithRed:((colorValue)&0xFF)/255.0 
						   green:((colorValue>>8)&0xFF)/255.0 
							blue:((colorValue>>16)&0xFF)/255.0 
						   alpha:1.0];
	
}

// Ignores alpha values.
- (NSString *)toHexString {

	int numComponents = CGColorGetNumberOfComponents([self CGColor]);
    
   	CGFloat *components = (CGFloat *)CGColorGetComponents([self CGColor]);
    NSString *hexString;
    
    
	switch (numComponents) 
	{
		case 2:
		{            
            int grayValue = components[0]*255;
            
            hexString = [NSString stringWithFormat:@"%02X%02X%02X", grayValue,grayValue,grayValue, nil]; 
			break;
		}
		case 4:
		{
            int redValue = components[0]*255;
            int greenValue = components[1]*255;
            int blueValue = components[2]*255;

            hexString = [NSString stringWithFormat:@"%02X%02X%02X", redValue,greenValue,blueValue, nil]; 
			break;
		}
        default:
        {
            hexString = @"FFFFFF";
            break;
        }
	}

    NSLog(@"HEX STRING FROM %@ -> %@", self, hexString);

    return hexString;
}

- (UIColor *)colorByChangingAlphaTo:(CGFloat)newAlpha
{
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self CGColor]);
	int numComponents = CGColorGetNumberOfComponents([self CGColor]);
	CGFloat newComponents[4];
    
	switch (numComponents) 
	{
		case 2:
		{
			//grayscale
			newComponents[0] = oldComponents[0];
			newComponents[1] = oldComponents[0];
			newComponents[2] = oldComponents[0];
			newComponents[3] = newAlpha;
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0];
			newComponents[1] = oldComponents[1];
			newComponents[2] = oldComponents[2];
			newComponents[3] = newAlpha;
			break;
		}
	}
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
	return retColor;
}


+ (UIColor *)colorForIndex:(NSInteger)index
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
	CGFloat components[4] = {0, 0, 0, 1};
    
	switch (index) {
		case 0:
			components[0] = 1;
			break;
		case 1:
			components[1] = 0.8;
			break;
		case 2:
			components[2] = 1;
			break;
			break;
		case 3:
			components[0] = 1;
			components[1] = 1;
			break;
		case 4:
			components[1] = 1;
			components[2] = 1;
			break;
		case 5:
			components[0] = 1;
			components[2] = 1;
			break;
		case 6:
			components[0] = 1;
			components[1] = 0.5;
			break;
		case 7:
			components[1] = 1;
			components[2] = 0.5;
			break;
		case 8:
			components[0] = 0.5;
			components[2] = 1;
			break;
		case 9:
			components[0] = 0.5;
			components[1] = 1;
			break;
		case 10:
			components[1] = 0.5;
			components[2] = 1;
			break;
		case 11:
			components[2] = 0.5;
			break;
		case 12:
			components[0] = 1;
			components[1] = 0.33;
			components[2] = 0.33;
			break;
		case 13:
			components[0] = 0.33;
			components[1] = 0.8;
			components[2] = 0.33;
			break;
		case 14:
			components[0] = 0.33;
			components[1] = 0.33;
			components[2] = 1;
			break;
		case 15:
			components[0] = 1;
			components[1] = 1;
			components[2] = 0.33;
			break;
		case 16:
			components[0] = 0.33;
			components[1] = 1;
			components[2] = 1;
			break;
		case 17:
			components[0] = 1;
			components[1] = 0.33;
			components[2] = 1;
			break;
		case 18:
			components[0] = 1;
			components[1] = 0.66;
			components[2] = 0.33;
			break;
		case 19:
			components[0] = 0.33;
			components[1] = 1;
			components[2] = 0.66;
			break;
		case 20:
			components[0] = 0.66;
			components[1] = 0.33;
			components[2] = 1;
			break;
		case 21:
			components[0] = 0.66;
			components[1] = 1;
			components[2] = 0.33;
			break;
		case 22:
			components[0] = 0.33;
			components[1] = 0.66;
			components[2] = 1;
			break;
		case 23:
			components[0] = 0.33;
			components[1] = 0.33;
			components[2] = 0.66;
			break;
	}
    
	CGColorRef newColor = CGColorCreate(colorSpace, components);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
	return retColor;
	// more colors: make each 0 -> 0.33 and each 0.5 a 0.66, Ones stay the same
}

@end
