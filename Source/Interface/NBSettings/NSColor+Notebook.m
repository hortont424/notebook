/*
 * Copyright 2011 Tim Horton. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY TIM HORTON "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL TIM HORTON OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * COPYRIGHT AND PERMISSION NOTICE (for colorFromHex:)
 *
 * Copyright © 2003 Karelia Software, LLC. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose
 * with or without fee is hereby granted, provided that the above copyright notice
 * and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS. IN NO EVENT
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
 * OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of a copyright holder shall not be
 * used in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization of the copyright holder.
 */

#import "NSColor+Notebook.h"

@implementation NSColor (Notebook)

+ (NSColor *)colorFromObject:(NSObject *)obj
{
    // Accepts four formats:

    // "System.controlColor"
    // "#ffffff"
    // [0.9, 0.9, 0.9]
    // [0.9, 0.9, 0.9, 0.5]

    if([obj isKindOfClass:[NSString class]])
    {
        NSString * str = (NSString *)obj;

        if([str hasPrefix:@"#"])
        {
            return [NSColor colorFromHex:str];
        }
        else
        {
            return [NSColor colorFromList:str];
        }
    }
    else if([obj isKindOfClass:[NSArray class]])
    {
        return [self colorFromRGB:(NSArray *)obj];
    }

    return nil;
}

+ (NSColor *)colorFromRGB:(NSArray *)rgbArray
{
    // TODO: better error checking (what if they're not NSNumbers)

    if([rgbArray count] == 3)
    {
        return [NSColor colorWithCalibratedRed:[[rgbArray objectAtIndex:0] floatValue]
                                         green:[[rgbArray objectAtIndex:1] floatValue]
                                          blue:[[rgbArray objectAtIndex:2] floatValue]
                                         alpha:1.0];
    }
    else if([rgbArray count] == 4)
    {
        return [NSColor colorWithCalibratedRed:[[rgbArray objectAtIndex:0] floatValue]
                                         green:[[rgbArray objectAtIndex:1] floatValue]
                                          blue:[[rgbArray objectAtIndex:2] floatValue]
                                         alpha:[[rgbArray objectAtIndex:3] floatValue]];
    }

    return nil;
}

+ (NSColor *)colorFromList:(NSString *)listId
{
    NSArray * names = [listId componentsSeparatedByString:@"."];

    if([names count] != 2)
    {
        return nil;
    }

    return [[NSColorList colorListNamed:[names objectAtIndex:0]] colorWithKey:[names objectAtIndex:1]];
}

+ (NSColor *)colorFromHex:(NSString *)hexString
{
    // TODO: support for alpha channel

    NSColor * result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;

    if([hexString hasPrefix:@"#"])
    {
        hexString = [hexString substringFromIndex:1];
    }

    NSScanner * scanner = [NSScanner scannerWithString:hexString];
    (void)[scanner scanHexInt:&colorCode];

    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode);

    result = [NSColor colorWithCalibratedRed:(float)redByte / 0xff
                                       green:(float)greenByte / 0xff
                                        blue:(float)blueByte / 0xff
                                       alpha:1.0];

    return result;
}

@end
