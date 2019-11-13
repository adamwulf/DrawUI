//
//  NSArray+MapReduce.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray <T> (MapReduce)

- (NSArray *)map : (id (^)(T obj, NSUInteger index))mapFunc;
- (NSArray *)mapWithSelector:(SEL)mapSelector;
- (id)reduce:(id (^)(T obj, NSUInteger index, id accum))reduceFunc;
- (BOOL)containsObjectIdenticalTo:(T)anObject;
- (NSArray<T> *)filter:(BOOL (^)(T obj, NSUInteger index))filterFunc;
- (BOOL)reduceToBOOL:(BOOL (^)(T obj, NSUInteger index, BOOL accum))reduceFunc;
- (id)firstResult:(id (^)(id obj, NSUInteger index, id accum))reducefunc;

@end
