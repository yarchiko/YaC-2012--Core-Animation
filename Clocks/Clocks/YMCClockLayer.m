//
//  BFBatteryTimeView.m
//  Clocks
//
//  Created by Vladislav Alekseev on 10.08.12.
//  Copyright (c) 2012 Yandex Mobile Camp. All rights reserved.
//

#import "YMCClockLayer.h"

@interface YMCClockLayer ()
@property (nonatomic, readonly) NSTimeInterval minutes, hours;
@end

@implementation YMCClockLayer

#pragma mark - Class Methods

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"time"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

+ (NSTimeInterval)animationDurationWithSourceTime:(NSTimeInterval)sourceTime targetTime:(NSTimeInterval)targetTime {
    NSTimeInterval sourceHours = [self hoursForTime:sourceTime];
    NSTimeInterval targetHours = [self hoursForTime:targetTime];
    NSTimeInterval diff = fabsf(sourceHours - targetHours);
    return diff * 0.5;
}

+ (NSTimeInterval)hoursForTime:(NSTimeInterval)time {
    NSTimeInterval h = time / 3600.0;
    return h;
}

+ (NSTimeInterval)minutesForTime:(NSTimeInterval)time {
    NSUInteger hours = [self hoursForTime:time];
    return time/60.0 - hours*60;
}

#pragma mark - Drawing

- (void)drawInContext:(CGContextRef)ctx {
    CGRect dirtyRect = CGContextGetClipBoundingBox(ctx);
    [self internalDrawInContext:ctx clippingRect:dirtyRect];
}

#pragma mark - Public

- (void)setTime:(NSTimeInterval)time {
    if (_time == time) {
        return;
    }
    _time = time;
}

- (BOOL)needsDisplayOnBoundsChange {
    return YES;
}

#pragma mark - Helper methods

- (CGRect)circleRectWithCenter:(CGPoint)center radius:(CGFloat)radius {
    return CGRectMake(center.x - radius, center.y - radius, radius*2, radius*2);
}

- (CGFloat)radiusFromCircleRect:(CGRect)rect {
    return CGRectGetWidth(rect)/2.0;
}

- (CGPoint)pointOnCircleWithCenter:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle {
    CGPoint point = CGPointMake(center.x + radius * cosf(angle),
                                center.y + radius * sinf(angle));
    return point;
}

- (NSTimeInterval)hours {
    return [[self class] hoursForTime:self.time];
}

- (NSTimeInterval)minutes {
    return [[self class] minutesForTime:self.time];
}

#pragma mark - Internal Drawing

- (void)internalDrawInContext:(CGContextRef)ctx clippingRect:(CGRect)rect {
    CGFloat lineWidth = CGRectGetWidth(self.bounds) * 0.025;
    
    CGRect bounds = self.bounds;
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGFloat boundsRadius = [self radiusFromCircleRect:bounds];
    
    CGFloat clockRadius = boundsRadius - lineWidth;
    CGRect clockRect = [self circleRectWithCenter:boundsCenter radius:clockRadius];
    
    CGFloat arrowSpinRadius = clockRadius * 0.10;
    CGRect arrowSpinRect = [self circleRectWithCenter:boundsCenter radius:arrowSpinRadius];
    
    NSTimeInterval minutes = self.minutes;
    NSTimeInterval hours = self.hours;
    CGFloat minutesAngle = -M_PI_2 + (2 * M_PI * minutes/60.0);
    CGFloat hoursAngle = -M_PI_2 + (2*M_PI * hours/12.0);
    
    // clip drawing to the circle around bounds rect
    CGContextAddEllipseInRect(ctx, self.bounds);
    CGContextEOClip(ctx);
    
    [self drawInnerShadowInContext:ctx bounds:bounds clockRect:clockRect lineWidth:lineWidth];
    [self drawArrowSpin:arrowSpinRect inContext:ctx clockRect:clockRect lineWidth:lineWidth];
    
    // hours arrow
    [self drawArrowWithAngle:hoursAngle
             arrowSpinRadius:arrowSpinRadius
                boundsCenter:boundsCenter
                      radius:0.5*boundsRadius
                       width:0.55
                     context:ctx];
    
    // minute arrow
    [self drawArrowWithAngle:minutesAngle
             arrowSpinRadius:arrowSpinRadius
                boundsCenter:boundsCenter
                      radius:0.7*boundsRadius
                       width:0.8
                     context:ctx];
    
    [self drawGlossInContext:ctx boundsRadius:boundsRadius boundsCenter:boundsCenter];
    
    [self drawClockTableInContext:ctx
                           bounds:bounds
                     boundsCenter:boundsCenter
                        clockRect:clockRect
                        lineWidth:lineWidth];
}

- (void)drawInnerShadowInContext:(CGContextRef)ctx bounds:(CGRect)bounds clockRect:(CGRect)clockRect lineWidth:(CGFloat)lineWidth {
    CGContextSaveGState(ctx);
            
    CGContextAddEllipseInRect(ctx, clockRect);
    CGContextClosePath(ctx);
    
    CGContextAddEllipseInRect(ctx, bounds);
    CGContextClosePath(ctx);
    
    CGContextEOFillPath(ctx);
    
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.15);
    CGContextSetLineWidth(ctx, lineWidth);
    
    CGRect shadowRect = bounds;
    shadowRect.origin.y += lineWidth*1.3;
    shadowRect.size.height -= lineWidth;
    shadowRect.origin.x += lineWidth*1.3;
    shadowRect.size.width -= lineWidth*1.3*2;
    CGContextAddEllipseInRect(ctx, shadowRect);
    CGContextStrokePath(ctx);
    
    CGContextRestoreGState(ctx);
}

- (void)drawArrowSpin:(CGRect)arrowSpinRect inContext:(CGContextRef)ctx clockRect:(CGRect)clockRect lineWidth:(CGFloat)lineWidth {
    CGRect dot = CGRectInset(arrowSpinRect, CGRectGetWidth(arrowSpinRect) * 0.25, CGRectGetHeight(arrowSpinRect) * 0.25);
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
    CGContextFillEllipseInRect(ctx, dot);
    
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextAddEllipseInRect(ctx, arrowSpinRect);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}

- (void)drawArrowWithAngle:(CGFloat)angle
           arrowSpinRadius:(CGFloat)arrowSpinRadius
              boundsCenter:(CGPoint)boundsCenter
                    radius:(CGFloat)radius
                     width:(CGFloat)width
                   context:(CGContextRef)ctx {
    CGPoint arrowSpinPoint = CGPointMake(boundsCenter.x + arrowSpinRadius * cosf(angle),
                                         boundsCenter.y + arrowSpinRadius * sinf(angle));
    CGPoint arrowSpinPointTop = CGPointMake(boundsCenter.x + arrowSpinRadius * cosf(angle + width),
                                            boundsCenter.y + arrowSpinRadius * sinf(angle + width));
    CGPoint pointDot = CGPointMake(boundsCenter.x + radius * cosf(angle),
                                   boundsCenter.y + radius * sinf(angle));
    CGPoint arrowSpinPointBottom = CGPointMake(boundsCenter.x + arrowSpinRadius * cosf(angle - width),
                                               boundsCenter.y + arrowSpinRadius * sinf(angle - width));
    
    CGContextMoveToPoint(ctx, arrowSpinPoint.x, arrowSpinPoint.y);
    CGContextAddLineToPoint(ctx, arrowSpinPointTop.x, arrowSpinPointTop.y);
    CGContextAddLineToPoint(ctx, pointDot.x, pointDot.y);
    CGContextAddLineToPoint(ctx, arrowSpinPointBottom.x, arrowSpinPointBottom.y);
    CGContextFillPath(ctx);
}

- (void)drawGlossInContext:(CGContextRef)ctx boundsRadius:(CGFloat)boundsRadius boundsCenter:(CGPoint)boundsCenter {
    CGContextSaveGState(ctx);
    
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 0.25);
    
    CGRect glossRect = [self circleRectWithCenter:boundsCenter radius:boundsRadius*0.9];
    glossRect.origin.y -= boundsRadius*0.01;
    glossRect.origin.x -= boundsRadius*0.001;
    glossRect.size.width += 2*boundsRadius*0.001;
    
    CGRect glossClearanceRect = [self circleRectWithCenter:boundsCenter radius:boundsRadius*2.5];
    glossClearanceRect.origin.y += boundsRadius*2.125;
    
    // clip drawing to the circle around bounds rect
    CGContextAddEllipseInRect(ctx, CGRectInset(glossRect, 1.0, 1.0));
    CGContextEOClip(ctx);
    
    CGContextAddEllipseInRect(ctx, glossRect);
    CGContextClosePath(ctx);
    
    CGContextAddEllipseInRect(ctx, glossClearanceRect);
    CGContextClosePath(ctx);
    
    CGContextEOFillPath(ctx);
    CGContextRestoreGState(ctx);
}

- (CGPoint)pointForText:(NSString *)text
                   font:(UIFont *)font
           boundsCenter:(CGPoint)boundsCenter
                 radius:(CGFloat)radius
                  angle:(CGFloat)angle {
    CGSize textSize = [text sizeWithFont:font];
    
    CGPoint point = [self pointOnCircleWithCenter:boundsCenter radius:radius angle:angle];
    point.x -= textSize.width/2;
    point.y += textSize.height/2 - textSize.height*0.1;
    return point;
}

- (UIFont *)validFontWithSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize];
}

- (void)drawClockTableInContext:(CGContextRef)ctx
                         bounds:(CGRect)bounds
                   boundsCenter:(CGPoint)boundsCenter
                      clockRect:(CGRect)clockRect
                      lineWidth:(CGFloat)lineWidth {
    CGContextSaveGState(ctx);
    
    CGFloat radius = CGRectGetWidth(clockRect)*0.80/2.0;
    CGFloat fontSize = lineWidth*4.75;
    CGFloat characterSpacing = fontSize/7.0;
    UIFont *font = [self validFontWithSize:fontSize];
    
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetShouldSmoothFonts(ctx, true);
    
    CGAffineTransform textTransform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(ctx, textTransform);
    CGContextSetCharacterSpacing(ctx, -characterSpacing);
    CGContextSelectFont(ctx,
                        [[font fontName] UTF8String],
                        [font pointSize],
                        kCGEncodingMacRoman);
    
    for (NSUInteger hour = 0; hour < 12; hour++) {
        CGFloat hoursAngle = -M_PI_2 + (2*M_PI * (CGFloat)hour/12.0);
        
        NSString *hourText = [NSString stringWithFormat:@"%u", (hour == 0 ? 12 : hour)];
        CGPoint textPoint = [self pointForText:hourText
                                          font:font
                                  boundsCenter:boundsCenter
                                        radius:radius
                                         angle:hoursAngle];
        if ([hourText length] > 1) {
            textPoint.x += characterSpacing * ([hourText length] - 1);
        }
        CGContextShowTextAtPoint(ctx, textPoint.x, textPoint.y, [hourText UTF8String], [hourText length]);
    }

    CGContextRestoreGState(ctx);
}

@end
