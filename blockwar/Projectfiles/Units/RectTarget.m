//
//  RectEntityTarget.m
//  takeover
//
//  Created by Darren Tsung on 1/7/14.
//
//

#import "RectTarget.h"

@implementation RectTarget

-(id) initWithRectLink:(CGRect *)rect andLink:(CGFloat *)theLink andLayer:(GameLayer *)theController
{
    if (self = [super init])
    {
        target = rect;
        targetHealth = theLink;
        controller = theController;
    }
    return self;
}

-(CGRect) boundingBox
{
    return *target;
}

-(void) actOnEntity:(Entity *)otherEntity
{
    if ([otherEntity isKindOfClass:[BossUnit class]])
    {
        [controller endGameWithWinState:@"enemy"];
    }
    else if ([otherEntity isKindOfClass:[Unit class]])
    {
        [(Unit *)otherEntity kill];
    }
}
@end
