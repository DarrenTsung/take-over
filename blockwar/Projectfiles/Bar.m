//
//  Bar.m
//  blockwar
//
//  Created by Darren Tsung on 11/1/13.
//
//

#import "Bar.h"

@implementation Bar

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor
{
    if ((self = [super init]))
    {
        // default size is 150 pixels
        size = CGSizeMake(150.0f, 10.0f);
        // default max is 120.0f
        max = 120.0f;
        current = 120.0f;
        
        origin = theOrigin;
        color = theColor;
        orientation = theOrientation;
        
        // default modifier is 1.0
        modifier = 1.0f;
        if ([orientation isEqualToString:@"Left"])
        {
            modifier *= -1.0;
        }
        else
        {
            modifier *= 1.0;
        }
    }
    return self;
}

-(void) draw
{
    if (current > 0.0f)
    {
        // opposite point to the origin of the health_bar
        CGPoint otherPoint = CGPointMake(origin.x + modifier*size.width*(current/max), origin.y - size.height);
        ccDrawSolidRect(origin, otherPoint, color);
    }
}

-(void) decreaseValueBy:(CGFloat) value
{
    current -= value;
}

-(void) resetValueToMax
{
    current = max;
}

-(CGFloat) getCurrentValue
{
    return current;
}


@end
