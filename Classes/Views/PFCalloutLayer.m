//
//  PFCalloutLayer.m
//  Disney Treasure Hunt
//
//  Created by Paul Alexander on 10/15/10.
//  Copyright (c) 2010 n/a. All rights reserved.
//

#import "PFCalloutLayer.h"
#import "PFDrawTools.h"

@interface PFCalloutLayer()

-(PFCalloutOrientation) calculateOrientationInRect: (CGRect) rect forPoint: (CGPoint) point;

@end

@implementation PFCalloutLayer

-(void) dealloc
{
    SafeRelease( baseColor );
    
    [super dealloc];
}

-(id) init
{
    if( self = [super init] )
    {
        baseColor = [[UIColor blackColor] colorWithAlphaComponent: .75];
        
        self.masksToBounds = NO;
        self.needsDisplayOnBoundsChange = YES;
        [self setNeedsDisplay];
        
        if( [self respondsToSelector: @selector(setContentsScale:)] )
            self.contentsScale = [[UIScreen mainScreen] scale];
        
        pointerLocation = CGPointZero;
        orientation = PFCalloutOrientationNone;

    }
    
    return self;
}

#pragma mark -
#pragma mark State

-(BOOL) isOpaque { return NO; }

-(UIColor *) baseColor { return baseColor; }
-(void) setBaseColor: (UIColor *) newBaseColor
{
    if( baseColor == newBaseColor )
        return;
    
    [baseColor release];
    baseColor = [newBaseColor retain];
    [self setNeedsDisplay];
}



-(CGPoint) pointerLocation { return pointerLocation; }
-(void) setPointerLocation: (CGPoint) point
{
    if( CGPointEqualToPoint( pointerLocation, point ) )
        return;

    CGRect newBounds = self.bounds;
    CGPoint center = self.position;
    
    switch( orientation )
    {
        case PFCalloutOrientationAbove:
            newBounds.size.height -= kPFCalloutPointerSize;
            center.y -= kPFCalloutPointerSize / 2;
            break;
        case PFCalloutOrientationBelow:
            newBounds.size.height -= kPFCalloutPointerSize;
            center.y += kPFCalloutPointerSize / 2;
            break;
        case PFCalloutOrientationRight:
            newBounds.size.width -= kPFCalloutPointerSize;
            center.x += kPFCalloutPointerSize / 2;
            break;
        case PFCalloutOrientationLeft:
            newBounds.size.width -= kPFCalloutPointerSize;
            center.x -= kPFCalloutPointerSize / 2;
            break;
    }
    
    // TODO adjust point to fit within corner radius and indicator size.
    
    orientation = [self calculateOrientationInRect: self.bounds forPoint: point];
    
    
    switch( orientation )
    {
        case PFCalloutOrientationAbove:
            newBounds.size.height += kPFCalloutPointerSize;
            center.y += kPFCalloutPointerSize / 2;
            break;
        case PFCalloutOrientationBelow:
            newBounds.size.height += kPFCalloutPointerSize;
            center.y -= kPFCalloutPointerSize / 2;
            break;            
        case PFCalloutOrientationRight:
            newBounds.size.width += kPFCalloutPointerSize;
            center.x -= kPFCalloutPointerSize / 2;
            break;
        case PFCalloutOrientationLeft:
            newBounds.size.width += kPFCalloutPointerSize;
            center.x += kPFCalloutPointerSize / 2;
            break;
    }
    
    
    pointerLocation = point;
    self.bounds = newBounds;
    self.position = center;
    
    [self setNeedsDisplay];
}


#pragma mark -
#pragma mark Drawing

-(CGRect) insetCalloutRect: (CGRect) rect
{
    CGRect insetBounds = rect;
    insetBounds.size.height -= kPFCalloutShadowSize;
    insetBounds.size.width -= kPFCalloutShadowSize;
    insetBounds.origin.x += kPFCalloutShadowSize / 2;
    
    return insetBounds;
}

-(PFCalloutOrientation) calculateOrientationInRect: (CGRect) rect forPoint: (CGPoint) point
{
    rect = [self insetCalloutRect: rect];    
    
    if( point.y >= CGRectGetMaxY( rect ) )
    {
        return PFCalloutOrientationAbove;
    }
    else if( point.y <= CGRectGetMinY( rect ) )
    {
        return PFCalloutOrientationBelow;
    }    
    else if( point.x <= CGRectGetMinX( rect ) )
    {
        return PFCalloutOrientationRight;
    }
    else if( point.x >= CGRectGetMaxX( rect ) )
    {
        return PFCalloutOrientationLeft;
    }
    
    return PFCalloutOrientationNone;
}

-(CGRect) insetRectForOrientation: (CGRect) rect orientation: (PFCalloutOrientation) insetOrientation pointerSize: (CGFloat) pointerSize
{
    switch( insetOrientation )
    {
        case PFCalloutOrientationAbove:
            rect.size.height -= pointerSize;
            break;
        case PFCalloutOrientationBelow:
            rect.size.height -= pointerSize;
            rect.origin.y += pointerSize;
            break;
        case PFCalloutOrientationRight:
            rect.size.width -= pointerSize;
            rect.origin.x += pointerSize;
            break;
        case PFCalloutOrientationLeft:
            rect.size.width -= pointerSize;
            break;
    }
    
    return rect;
}

-(CGMutablePathRef) createPathInRect: (CGRect) outerRect cornerRadius: (CGFloat) radius pointerSize: (CGFloat) pointerSize inset: (CGFloat) inset
{
    
    outerRect = CGRectInset( outerRect, inset, inset );
    CGRect rect = [self insetRectForOrientation: outerRect orientation: orientation pointerSize: pointerSize];
    
    CGMutablePathRef path = CGPathCreateMutable();
	
	// top right arc
	CGPathAddArc( path, 
                 nil, 
                 CGRectGetMaxX( rect ) - radius, 
                 CGRectGetMinY( rect ) + radius, 
                 radius, 
                 -M_PI / 2, 
                 0,
                 NO );
    
    if( orientation == PFCalloutOrientationLeft )
    {
        CGPathAddLineToPoint( path, NULL, CGRectGetMaxX( rect ), pointerLocation.y + pointerSize );
        CGPathAddLineToPoint( path, NULL, CGRectGetMaxX( outerRect ) - ( inset / 2 ), pointerLocation.y );
        CGPathAddLineToPoint( path, NULL, CGRectGetMaxX( rect ), pointerLocation.y - pointerSize );
    }
    
	// bottom right arc
	CGPathAddArc( path, 
				 nil, 
				 CGRectGetMaxX( rect ) - radius, 
				 CGRectGetMaxY( rect ) - radius, 
				 radius, 
				 0, 
				 M_PI / 2,
				 NO );
	

	if( orientation == PFCalloutOrientationAbove )
    {
        CGPathAddLineToPoint( path, NULL, pointerLocation.x + pointerSize, CGRectGetMaxY( rect ) );
        CGPathAddLineToPoint( path, NULL, pointerLocation.x, CGRectGetMaxY( outerRect ) - ( inset / 2 ) );
        CGPathAddLineToPoint( path, NULL, pointerLocation.x - pointerSize, CGRectGetMaxY( rect ) );
    }
         
	
	// bottom left arc
	CGPathAddArc( path, 
				 nil, 
				 CGRectGetMinX( rect ) + radius, 
				 CGRectGetMaxY( rect ) - radius, 
				 radius, 
				 M_PI / 2, 
				 M_PI,
				 NO );
    
    
	if( orientation == PFCalloutOrientationRight )
    {
        CGPathAddLineToPoint( path, NULL, CGRectGetMinX( rect ), pointerLocation.y + pointerSize );
        CGPathAddLineToPoint( path, NULL, CGRectGetMinX( outerRect ) + ( inset / 2 ), pointerLocation.y );
        CGPathAddLineToPoint( path, NULL, CGRectGetMinX( rect ), pointerLocation.y - pointerSize );
    }
	
	// top left arc
	CGPathAddArc( path, 
				 nil, 
				 CGRectGetMinX( rect ) + radius, 
				 CGRectGetMinY( rect ) + radius, 
				 radius, 
				 M_PI, 
				 M_PI * 1.5,
				 NO );
	
	if( orientation == PFCalloutOrientationBelow )
    {
        CGPathAddLineToPoint( path, NULL, pointerLocation.x + pointerSize, CGRectGetMinY( rect ) );
        CGPathAddLineToPoint( path, NULL, pointerLocation.x, CGRectGetMinY( outerRect ) + ( inset / 2 ) );
        CGPathAddLineToPoint( path, NULL, pointerLocation.x - pointerSize, CGRectGetMinY( rect ) );
    }
	
	CGPathCloseSubpath( path );
    
    
    return path;
}




-(void) drawInContext: (CGContextRef) g
{
    
    CGMutablePathRef path;
    

    // Diagnostic to help visualize where the layer is located.
//    CGContextSetFillColorWithColor( g, [[[UIColor blueColor] colorWithAlphaComponent: .5] CGColor] );
//    CGContextFillRect( g, self.bounds );
    
    CGRect insetBounds = [self insetCalloutRect: self.bounds];
    CGRect rect = CGRectInset( insetBounds, 0.5, 0.5 );



    
    // Drop shadow
    CGContextSaveGState( g );
    path = [self createPathInRect: rect cornerRadius: kPFCalloutCornerRadius pointerSize: kPFCalloutPointerSize inset: 0.0];
    CGContextAddRect( g, self.bounds );
    CGContextAddPath( g, path );
    CGContextEOClip( g );
    CGPathRelease( path );
    

    path = [self createPathInRect: rect cornerRadius: kPFCalloutCornerRadius pointerSize: kPFCalloutPointerSize inset: 0.0];
    CGContextAddPath( g, path );
    CGColorRef shadowColor = [[UIColor colorWithRed: 0 green: 0 blue: 0 alpha: .85] CGColor];
    CGContextSetShadowWithColor( g, CGSizeMake( 0, kPFCalloutShadowSize / 2 ), kPFCalloutShadowSize, shadowColor );
    CGContextSetFillColorWithColor( g, shadowColor );
    CGContextFillPath( g );
    CGPathRelease( path );
    CGContextRestoreGState( g );
    
    
    // base rounded rectangle with pointer
    path = [self createPathInRect: rect cornerRadius: kPFCalloutCornerRadius pointerSize: kPFCalloutPointerSize inset: 0.0];
    CGContextSetFillColorWithColor( g, [baseColor CGColor] );
    CGContextAddPath( g, path );
    CGContextFillPath( g );
    CGPathRelease( path );
    
    
    // Outer stroke
    rect = CGRectInset( rect, 0.5, 0.5 );
    path = [self createPathInRect: rect cornerRadius: kPFCalloutCornerRadius pointerSize: kPFCalloutPointerSize inset: 0.0];
    CGContextSetLineWidth( g, 1 );
    CGContextSetStrokeColorWithColor( g, [[baseColor colorWithAlphaComponent: .35] CGColor] );
    CGContextAddPath( g, path );
    CGContextStrokePath( g );
    CGPathRelease( path );
    
    // Secondary rectangle creates a light highlight around the entire area
    path = [self createPathInRect: rect cornerRadius: kPFCalloutCornerRadius - 0.5 pointerSize: kPFCalloutPointerSize inset: 1.5];
    CGContextSetFillColorWithColor( g, [[baseColor colorWithAlphaComponent: 0.1] CGColor] );
    CGContextAddPath( g, path );
    CGContextFillPath( g );
    CGPathRelease( path );
    
    
    // Glassy gloss highlight
    CGRect insetRect = [self insetRectForOrientation: CGRectInset( insetBounds, .5, .5) orientation: orientation pointerSize: kPFCalloutPointerSize];
    if( orientation == PFCalloutOrientationAbove )
    {
        rect = CGRectInset( insetRect, 1, 1 );
        rect.size.height -= ( CGRectGetHeight( rect ) / 2 ) - 2;
        path = [PFDrawTools createPathForRect: rect withCornerRadius: kPFCalloutCornerRadius];
    }
    else
    {
        rect.size.height -= ( CGRectGetHeight( insetRect ) / 2 ) - 1;
        path = [self createPathInRect: rect cornerRadius: kPFCalloutCornerRadius pointerSize: kPFCalloutPointerSize inset: 0];
    }
    
    CGContextAddPath( g, path );
    CGContextSaveGState( g );
    CGContextClip( g );
    CGColorRef colors[] = 
    { 
        [[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.3] CGColor],
        [[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.1] CGColor],
        
    };
	
	CFArrayRef colorsRef = CFArrayCreate( NULL, (const void**)colors, 2, NULL );
	
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradientRef = CGGradientCreateWithColors( colorSpaceRef, colorsRef, NULL );
    
	CGContextDrawLinearGradient( g, gradientRef, CGPointMake( 0, CGRectGetMinY( insetRect ) ), CGPointMake( 0, CGRectGetMaxY( rect ) ),
                                kCGGradientDrawsBeforeStartLocation );
    
	CGColorSpaceRelease( colorSpaceRef );
	CGGradientRelease( gradientRef );
	CGPathRelease( path );
	CFRelease( colorsRef );
    CGContextRestoreGState( g );
    
    
        
    // Top highlight  accent
    

    
    rect = CGRectInset( insetBounds, 0, 0.5 );
    //    rect.origin.y += 0.5;
    rect.size.height += 1.5;

    path = [self createPathInRect: rect cornerRadius: kPFCalloutCornerRadius pointerSize: kPFCalloutPointerSize inset: 1.5];
    
    CGContextAddRect( g, insetBounds );
    CGContextAddPath( g, path );
    CGContextEOClip( g );
    CGPathRelease( path );

    
    path = [self createPathInRect: insetBounds cornerRadius: kPFCalloutCornerRadius - 0.5 pointerSize: kPFCalloutPointerSize inset: 1.5];
    CGContextAddPath( g, path );
    CGContextEOClip( g );

    CGContextSetFillColorWithColor( g, [[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.5] CGColor] );
    CGContextFillRect( g, CGRectMake( CGRectGetMinX( insetBounds ), 0, CGRectGetWidth( insetBounds ), CGRectGetHeight( insetBounds ) ) ); 

}


@end