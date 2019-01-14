//
//  RNDrawCanvasData.m
//  RNDrawCanvas
//
//  Created by terry on 03/08/2017.
//  Copyright © 2017 Terry. All rights reserved.
//

#import "RNDrawData.h"
#import "Utility.h"

@interface RNDrawData ()

@property (nonatomic, readwrite) int pathId;
@property (nonatomic, readwrite) CGFloat strokeWidth;
@property (nonatomic, readwrite) UIColor* strokeColor;
@property (nonatomic, readwrite) NSMutableArray<NSValue*> *points;
@property (nonatomic, readwrite) NSMutableArray<NSValue*> *points1;
@property (nonatomic, readwrite) NSMutableArray<NSValue*> *points2;
@property (nonatomic, readwrite) NSMutableArray<NSValue*> *points3;
@property (nonatomic, readwrite) NSMutableArray<NSValue*> *points4;

@end

@implementation RNDrawData
{
    CGRect _dirty;
    UIBezierPath *_path;
    UIBezierPath *_path1;
    UIBezierPath *_path2;
    UIBezierPath *_path3;
    UIBezierPath *_path4;
}

- (instancetype)initWithId:(int) pathId strokeColor:(UIColor*) strokeColor strokeWidth:(int) strokeWidth {
    self = [super init];
    if (self) {
        _pathId = pathId;
        _strokeColor = strokeColor;
        _strokeWidth = strokeWidth;
        _points = [NSMutableArray new];
        _points1 = [NSMutableArray new];
        _points2 = [NSMutableArray new];
        _points3 = [NSMutableArray new];
        _points4 = [NSMutableArray new];
        _isTranslucent = CGColorGetComponents(strokeColor.CGColor)[3] != 1.0 &&
        ![Utility isSameColor:strokeColor color:[UIColor clearColor]];
        _path = _isTranslucent ? [UIBezierPath new] : nil;
        _path1 = _isTranslucent ? [UIBezierPath new] : nil;
        _path2 = _isTranslucent ? [UIBezierPath new] : nil;
        _path3 = _isTranslucent ? [UIBezierPath new] : nil;
        _path4 = _isTranslucent ? [UIBezierPath new] : nil;
        _dirty = CGRectZero;
    }
    return self;
}

- (instancetype)initWithId:(int) pathId strokeColor:(UIColor*) strokeColor strokeWidth:(int) strokeWidth points: (NSArray*) points {
    self = [super init];
    if (self) {
        _pathId = pathId;
        _strokeColor = strokeColor;
        _strokeWidth = strokeWidth;
        _points = [points mutableCopy];
        _points1 = [points mutableCopy];
        _points2 = [points mutableCopy];
        _points3 = [points mutableCopy];
        _points4 = [points mutableCopy];
        _isTranslucent = CGColorGetComponents(strokeColor.CGColor)[3] != 1.0 &&
        ![Utility isSameColor:strokeColor color:[UIColor clearColor]];
        _path = _isTranslucent ? [self evaluatePath] : nil;
        _path1 = _isTranslucent ? [self evaluatePath1] : nil;
        _path2 = _isTranslucent ? [self evaluatePath2] : nil;
        _path3 = _isTranslucent ? [self evaluatePath3] : nil;
        _path4 = _isTranslucent ? [self evaluatePath4] : nil;
        _dirty = CGRectZero;
    }
    return self;
}

- (int)number {
    int r = arc4random() % ((int)_strokeWidth / 2);
    if (r < 1) r = 1;
    return r;
}

- (CGRect)addPoint:(CGPoint) point {
    [_points addObject: [NSValue valueWithCGPoint: point]];
    
    CGRect updateRect;
    
    NSUInteger pointsCount = _points.count;
    
    CGPoint point1 = CGPointMake(point.x - [self number], point.y - [self number]);
    CGPoint point2 = CGPointMake(point.x + [self number], point.y - [self number]);
    CGPoint point3 = CGPointMake(point.x + [self number], point.y + [self number]);
    CGPoint point4 = CGPointMake(point.x - [self number], point.y + [self number]);
    
    [_points1 addObject: [NSValue valueWithCGPoint: point1]];
    [_points2 addObject: [NSValue valueWithCGPoint: point2]];
    [_points3 addObject: [NSValue valueWithCGPoint: point3]];
    [_points4 addObject: [NSValue valueWithCGPoint: point4]];
    
    if (_isTranslucent) {
        if (pointsCount >= 3) {
            [_path1 moveToPoint: [_points1[_points1.count - 2] CGPointValue]];
            [_path1 addLineToPoint: point1];
            [_path2 moveToPoint: [_points2[_points2.count - 2] CGPointValue]];
            [_path2 addLineToPoint: point2];
            
            [_path moveToPoint: [_points[_points.count - 2] CGPointValue]];
            [_path addLineToPoint: point];
            
            [_path3 moveToPoint: [_points3[_points3.count - 2] CGPointValue]];
            [_path3 addLineToPoint: point3];
            [_path4 moveToPoint: [_points4[_points4.count - 2] CGPointValue]];
            [_path4 addLineToPoint: point4];
        } else if (pointsCount >= 2) {
            [_path1 moveToPoint: [_points1[0] CGPointValue]];
            [_path1 addLineToPoint: point1];
            [_path2 moveToPoint: [_points2[0] CGPointValue]];
            [_path2 addLineToPoint: point2];
            
            [_path moveToPoint: [_points[0] CGPointValue]];
            [_path addLineToPoint: point];
            
            [_path3 moveToPoint: [_points3[0] CGPointValue]];
            [_path3 addLineToPoint: point3];
            [_path4 moveToPoint: [_points4[0] CGPointValue]];
            [_path4 addLineToPoint: point4];
        } else {
            [_path1 moveToPoint: point1];
            [_path1 addLineToPoint: point1];
            [_path2 moveToPoint: point2];
            [_path2 addLineToPoint: point2];
            
            [_path moveToPoint: point];
            [_path addLineToPoint: point];
            
            [_path3 moveToPoint: point3];
            [_path3 addLineToPoint: point3];
            [_path4 moveToPoint: point4];
            [_path4 addLineToPoint: point4];
        }
        
        CGFloat x = point3.x, y = point3.y;
        _dirty = CGRectIsEmpty(_dirty) ? CGRectMake(x, y, 1, 1) : CGRectUnion(_dirty, CGRectMake(x, y, 1, 1));
        updateRect = CGRectInset(_dirty, -_strokeWidth * 2, -_strokeWidth * 2);
    } else {
        if (pointsCount >= 3) {
            CGPoint a = _points[pointsCount - 3].CGPointValue;
            CGPoint b = _points[pointsCount - 2].CGPointValue;
            CGPoint c = point;
            CGPoint prevMid = midPoint(a, b);
            CGPoint currentMid = midPoint(b, c);
            
            updateRect = CGRectMake(prevMid.x, prevMid.y, 0, 0);
            updateRect = CGRectUnion(updateRect, CGRectMake(b.x, b.y, 0, 0));
            updateRect = CGRectUnion(updateRect, CGRectMake(currentMid.x, currentMid.y, 0, 0));
        } else if (pointsCount >= 2) {
            CGPoint a = _points[pointsCount - 2].CGPointValue;
            CGPoint b = point;
            CGPoint mid = midPoint(a, b);
            
            updateRect = CGRectMake(a.x, a.y, 0, 0);
            updateRect = CGRectUnion(updateRect, CGRectMake(mid.x, mid.y, 0, 0));
        } else {
            updateRect = CGRectMake(point.x, point.y, 0, 0);
        }
        
        updateRect = CGRectInset(updateRect, -_strokeWidth * 2, -_strokeWidth * 2);
    }
    
    return updateRect;
}

- (void)drawLastPointInContext:(CGContextRef)context {
    NSUInteger pointsCount = _points.count;
    if (pointsCount < 1) {
        return;
    };
    
    [self drawInContext:context pointIndex:pointsCount - 1];
}
- (void)drawInContext:(CGContextRef)context {
    if (_isTranslucent) {
        CGContextSetLineWidth(context, _strokeWidth);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetStrokeColorWithColor(context, [_strokeColor CGColor]);
        CGContextSetAlpha(context, 0.3f);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        CGContextAddPath(context, _path1.CGPath);
        CGContextAddPath(context, _path2.CGPath);
        CGContextAddPath(context, _path.CGPath);
        CGContextAddPath(context, _path3.CGPath);
        CGContextAddPath(context, _path4.CGPath);
        CGContextStrokePath(context);
    } else {
        NSUInteger pointsCount = _points.count;
        for (NSUInteger i = 0; i < pointsCount; i++) {
            [self drawInContext:context pointIndex:i];
        }
    }
}

- (void)drawInContext:(CGContextRef)context pointIndex:(NSUInteger)pointIndex {
    NSUInteger pointsCount = _points.count;
    if (pointIndex >= pointsCount) {
        return;
    };
    
    BOOL isErase = [Utility isSameColor:_strokeColor color:[UIColor clearColor]];
    
    CGContextSetStrokeColorWithColor(context, _strokeColor.CGColor);
    CGContextSetLineWidth(context, _strokeWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    if (!isErase) {
        CGContextSetAlpha(context, 0.3f);
    }
    CGContextSetBlendMode(context, isErase ? kCGBlendModeClear : kCGBlendModeNormal);
    CGContextBeginPath(context);
    
    if (pointsCount >= 3 && pointIndex >= 2) {
        CGPoint b1 = _points1[pointIndex - 1].CGPointValue;
        CGPoint c1 = _points1[pointIndex].CGPointValue;
        CGContextMoveToPoint(context, b1.x, b1.y);
        CGContextAddLineToPoint(context, c1.x, c1.y);
        
        CGPoint b = _points[pointIndex - 1].CGPointValue;
        CGPoint c = _points[pointIndex].CGPointValue;
        CGContextMoveToPoint(context, b.x, b.y);
        CGContextAddLineToPoint(context, c.x, c.y);
        
        CGPoint b2 = _points2[pointIndex - 1].CGPointValue;
        CGPoint c2 = _points2[pointIndex].CGPointValue;
        CGContextMoveToPoint(context, b2.x, b2.y);
        CGContextAddLineToPoint(context, c2.x, c2.y);
        
    } else if (pointsCount >= 2 && pointIndex >= 1) {
        CGPoint b1 = _points1[pointIndex - 1].CGPointValue;
        CGPoint c1 = _points1[pointIndex].CGPointValue;
        CGContextMoveToPoint(context, b1.x, b1.y);
        CGContextAddLineToPoint(context, c1.x, c1.y);
        
        CGPoint b = _points[pointIndex - 1].CGPointValue;
        CGPoint c = _points[pointIndex].CGPointValue;
        CGContextMoveToPoint(context, b.x, b.y);
        CGContextAddLineToPoint(context, c.x, c.y);
        
        CGPoint b2 = _points2[pointIndex - 1].CGPointValue;
        CGPoint c2 = _points2[pointIndex].CGPointValue;
        CGContextMoveToPoint(context, b2.x, b2.y);
        CGContextAddLineToPoint(context, c2.x, c2.y);
    } else if (pointsCount >= 1) {
        CGPoint a1 = _points1[pointIndex].CGPointValue;
        
        // Draw a single point
        CGContextMoveToPoint(context, a1.x, a1.y);
        CGContextAddLineToPoint(context, a1.x, a1.y);
        
        CGPoint a = _points[pointIndex].CGPointValue;
        
        // Draw a single point
        CGContextMoveToPoint(context, a.x, a.y);
        CGContextAddLineToPoint(context, a.x, a.y);
        
        CGPoint a2 = _points2[pointIndex].CGPointValue;
        
        // Draw a single point
        CGContextMoveToPoint(context, a2.x, a2.y);
        CGContextAddLineToPoint(context, a2.x, a2.y);
    }
    
    CGContextStrokePath(context);
}

// Translucent
- (UIBezierPath*) evaluatePath {
    NSUInteger pointsCount = _points.count;
    UIBezierPath *path = [UIBezierPath new];
    
    for(NSUInteger pointIndex=0; pointIndex<pointsCount; pointIndex++) {
        if (pointsCount >= 3 && pointIndex >= 2) {
            CGPoint b = _points[pointIndex - 1].CGPointValue;
            CGPoint c = _points[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 2 && pointIndex >= 1) {
            CGPoint b = _points[pointIndex - 1].CGPointValue;
            CGPoint c = _points[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 1) {
            CGPoint c = _points[pointIndex].CGPointValue;
            [path moveToPoint: c];
            [path addLineToPoint: c];
        }
    }
    return path;
}

- (UIBezierPath*) evaluatePath1 {
    NSUInteger pointsCount = _points1.count;
    UIBezierPath *path = [UIBezierPath new];
    
    for(NSUInteger pointIndex=0; pointIndex<pointsCount; pointIndex++) {
        if (pointsCount >= 3 && pointIndex >= 2) {
            CGPoint b = _points1[pointIndex - 1].CGPointValue;
            CGPoint c = _points1[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 2 && pointIndex >= 1) {
            CGPoint b = _points1[pointIndex - 1].CGPointValue;
            CGPoint c = _points1[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 1) {
            CGPoint c = _points1[pointIndex].CGPointValue;
            [path moveToPoint: c];
            [path addLineToPoint: c];
        }
    }
    return path;
}

- (UIBezierPath*) evaluatePath2 {
    NSUInteger pointsCount = _points2.count;
    UIBezierPath *path = [UIBezierPath new];
    
    for(NSUInteger pointIndex=0; pointIndex<pointsCount; pointIndex++) {
        if (pointsCount >= 3 && pointIndex >= 2) {
            CGPoint b = _points2[pointIndex - 1].CGPointValue;
            CGPoint c = _points2[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 2 && pointIndex >= 1) {
            CGPoint b = _points2[pointIndex - 1].CGPointValue;
            CGPoint c = _points2[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 1) {
            CGPoint c = _points2[pointIndex].CGPointValue;
            [path moveToPoint: c];
            [path addLineToPoint: c];
        }
    }
    return path;
}

- (UIBezierPath*) evaluatePath3 {
    NSUInteger pointsCount = _points3.count;
    UIBezierPath *path = [UIBezierPath new];
    
    for(NSUInteger pointIndex=0; pointIndex<pointsCount; pointIndex++) {
        if (pointsCount >= 3 && pointIndex >= 2) {
            CGPoint b = _points3[pointIndex - 1].CGPointValue;
            CGPoint c = _points3[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 2 && pointIndex >= 1) {
            CGPoint b = _points3[pointIndex - 1].CGPointValue;
            CGPoint c = _points3[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 1) {
            CGPoint c = _points3[pointIndex].CGPointValue;
            [path moveToPoint: c];
            [path addLineToPoint: c];
        }
    }
    return path;
}

- (UIBezierPath*) evaluatePath4 {
    NSUInteger pointsCount = _points4.count;
    UIBezierPath *path = [UIBezierPath new];
    
    for(NSUInteger pointIndex=0; pointIndex<pointsCount; pointIndex++) {
        if (pointsCount >= 3 && pointIndex >= 2) {
            CGPoint b = _points4[pointIndex - 1].CGPointValue;
            CGPoint c = _points4[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 2 && pointIndex >= 1) {
            CGPoint b = _points4[pointIndex - 1].CGPointValue;
            CGPoint c = _points4[pointIndex].CGPointValue;
            [path moveToPoint: b];
            [path addLineToPoint: c];
        } else if (pointsCount >= 1) {
            CGPoint c = _points4[pointIndex].CGPointValue;
            [path moveToPoint: c];
            [path addLineToPoint: c];
        }
    }
    return path;
}


@end
