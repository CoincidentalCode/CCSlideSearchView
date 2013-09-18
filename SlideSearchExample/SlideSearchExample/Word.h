//
//  Word.h
//  SlideSearchExample
//
//  Created by Tom Bachant on 8/12/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Word : NSObject

@property (nonatomic, strong) NSString *value;
@property (nonatomic)         NSInteger index;

+ (instancetype)wordWithString:(NSString *)string index:(NSInteger)index;

@end
