//
//  NSArray+MapReduce.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "NSArray+MapReduce.h"


@implementation NSArray (MapReduce)

- (NSArray *)map:(id (^)(id obj, NSUInteger index))mapfunc
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSUInteger index;
    for (index = 0; index < [self count]; index++) {
        id foo = mapfunc([self objectAtIndex:index], index);
        if (foo) {
            [result addObject:foo];
        }
    }
    return result;
}

- (NSArray *)mapWithSelector:(SEL)mapSelector
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSUInteger index;
    for (index = 0; index < [self count]; index++) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [result addObject:[[self objectAtIndex:index] performSelector:mapSelector]];
#pragma clang diagnostic pop
    }
    return result;
}

- (id)firstResult:(id (^)(id obj, NSUInteger index, id accum))reducefunc
{
    id result = NULL;
    NSUInteger index;
    for (index = 0; index < [self count]; index++) {
        result = reducefunc([self objectAtIndex:index], index, result);
        if (result)
            break;
    }
    return result;
}

- (id)reduce:(id (^)(id obj, NSUInteger index, id accum))reducefunc
{
    id result = NULL;
    NSUInteger index;
    for (index = 0; index < [self count]; index++) {
        result = reducefunc([self objectAtIndex:index], index, result);
    }
    return result;
}

- (BOOL)reduceToBOOL:(BOOL (^)(id, NSUInteger, BOOL))reduceFunc
{
    BOOL result = NO;
    NSUInteger index;
    for (index = 0; index < [self count]; index++) {
        result = reduceFunc([self objectAtIndex:index], index, result);
    }
    return result;
}

- (BOOL)containsObjectIdenticalTo:(id)anObject
{
    for (id obj in self) {
        if (obj == anObject) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)filter:(BOOL (^)(id obj, NSUInteger index))filterFunc
{
    NSMutableArray *ret = [NSMutableArray array];
    for (NSInteger index = 0; index < [self count]; index++) {
        id obj = [self objectAtIndex:index];
        if (filterFunc(obj, index)) {
            [ret addObject:obj];
        }
    }
    return ret;
}

@end
