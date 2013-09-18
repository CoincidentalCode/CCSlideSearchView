//
//  Word.m
//  SlideSearchExample
//
//  Created by Tom Bachant on 8/12/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import "Word.h"

@implementation Word

+ (instancetype)wordWithString:(NSString *)string index:(NSInteger)indx {
    Word *w = [Word new];
    
    w.value = string;
    w.index = indx;
    
    return w;
}

@end
