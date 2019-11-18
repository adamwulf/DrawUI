//
//  DotSegment.m
//  JotUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import "MMMoveToPathElement.h"
#import "MMAbstractBezierPathElement-Protected.h"


@implementation MMMoveToPathElement {
    // cache the hash, since it's expenseive to calculate
    NSUInteger _hashCache;
}

- (id)initWithMoveTo:(CGPoint)point
{
    if (self = [super initWithStart:point]) {
        NSUInteger prime = 31;
        _hashCache = 1;
        _hashCache = prime * _hashCache + [self startPoint].x;
        _hashCache = prime * _hashCache + [self startPoint].y;
    }
    return self;
}

+ (id)elementWithMoveTo:(CGPoint)point
{
    return [[MMMoveToPathElement alloc] initWithMoveTo:point];
}

/**
 * we're just 1 point, so we have zero length
 */
- (CGFloat)lengthOfElement
{
    return 0;
}

- (CGFloat)angleOfStart
{
    return 0;
}

- (CGFloat)angleOfEnd
{
    return 0;
}

- (UIBezierPath *)borderPath
{
    return [UIBezierPath bezierPathWithOvalInRect:[self bounds]];
}

- (CGRect)bounds
{
    return CGRectInset(CGRectMake([self startPoint].x, [self startPoint].y, 0, 0), -[self width], -[self width]);
}

- (CGPoint)endPoint
{
    return self.startPoint;
}

/**
 * only 1 step to show our single point
 */
- (NSInteger)numberOfSteps
{
    return 0;
}

- (NSInteger)numberOfBytes
{
    return 0;
}

- (struct ColorfulVertex *)generatedVertexArrayForScale:(CGFloat)scale
{
    return NULL;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[Move to: %f,%f]", [self startPoint].x, [self startPoint].y];
}

#pragma mark - Events

- (void)updateWithEvent:(MMTouchStreamEvent *)event
{
    [self setStartPoint:[event location]];
}

#pragma mark - PlistSaving

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    if (self = [super initFromDictionary:dictionary]) {
        NSUInteger prime = 31;
        _hashCache = 1;
        _hashCache = prime * _hashCache + [self startPoint].x;
        _hashCache = prime * _hashCache + [self startPoint].y;
    }
    return self;
}

- (UIBezierPath *)bezierPathSegment
{
    UIBezierPath *strokePath = [UIBezierPath bezierPath];
    [strokePath moveToPoint:self.startPoint];
    return strokePath;
}


#pragma mark - hashing and equality

- (NSUInteger)hash
{
    return _hashCache;
}

- (BOOL)isEqual:(id)object
{
    return self == object || [self hash] == [object hash];
}

@end
