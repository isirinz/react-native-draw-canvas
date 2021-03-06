//
//  RNDrawCanvasData.h
//  RNDrawCanvas
//
//  Created by terry on 03/08/2017.
//  Copyright © 2017 Terry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RNDrawData : NSObject

@property (nonatomic, readonly) int pathId;
@property (nonatomic, readonly) CGFloat strokeWidth;
@property (nonatomic, readonly) UIColor* strokeColor;
@property (nonatomic, readonly) NSArray<NSValue*> *points;
@property (nonatomic, readonly) NSArray<NSValue*> *points1;
@property (nonatomic, readonly) NSArray<NSValue*> *points2;
@property (nonatomic, readonly) NSArray<NSValue*> *points3;
@property (nonatomic, readonly) NSArray<NSValue*> *points4;
@property (nonatomic, readonly) BOOL isTranslucent;

- (instancetype)initWithId:(int) pathId strokeColor:(UIColor*) strokeColor strokeWidth:(int) strokeWidth points: (NSArray*) points;
- (instancetype)initWithId:(int) pathId strokeColor:(UIColor*) strokeColor strokeWidth:(int) strokeWidth;

- (CGRect)addPoint:(CGPoint) point;

- (void)drawLastPointInContext:(CGContextRef)context;
- (void)drawInContext:(CGContextRef)context;

@end
