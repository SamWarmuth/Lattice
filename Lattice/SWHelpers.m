//
//  SWHelpers.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/11/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "SWHelpers.h"

@implementation SWHelpers

+ (NSDate *)dateFromRailsDateString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    "created_at" = "2012-09-11T17:57:49Z";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)fixNewlinesInString:(NSString *)string
{
    return [[string stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
}

+ (NSString *)removeEmojiFromString:(NSString *)string
{
    __block NSMutableString* temp = [NSMutableString string];
    
    [string enumerateSubstringsInRange: NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         
         const unichar hs = [substring characterAtIndex: 0];
         
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             const unichar ls = [substring characterAtIndex: 1];
             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
             
             [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"-": substring]; // U+1D000-1F77F
             
             // non surrogate
         } else {
             [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? @"-": substring]; // U+2100-26FF
         }
     }];
    
    return temp;
}

@end
