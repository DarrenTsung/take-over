//
//  HealthBar.m
//  blockwar
//
//  Created by Darren Tsung on 11/1/13.
//
//

#import "HealthBar.h"

@implementation HealthBar

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor
{
    if ((self = [super init]))
    {
        // default size is 150 pixels
        size = CGSizeMake(150.0f, 10.0f);
        // default max health is 120.0f
        max_health = 120.0f;
        current_health = 120.0f;
        
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
    if (current_health > 0.0f)
    {
        // opposite point to the origin of the health_bar
        CGPoint otherPoint = CGPointMake(origin.x + modifier*size.width*(current_health/max_health), origin.y - size.height);
        ccDrawSolidRect(origin, otherPoint, color);
    }
}

-(void) decreaseHealthBy:(CGFloat) value
{
    current_health -= value;
}

-(CGFloat) getCurrentValue
{
    return current_health;
}

@end
