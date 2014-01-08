//
//  RectEntityTarget.m
//  takeover
//
//  Created by Darren Tsung on 1/7/14.
//
//

#import "RectTarget.h"

@implementation RectTarget

-(id) initWithRect:(CGRect)rect andLink:(CGFloat *)theLink
{
    if (self = [super init])
    {
        target = rect;
        targetHealth = theLink;
    }
    return self;
}

-(CGRect) boundingBox
{
    return target;
}

-(void) actOnEntity:(Entity *)otherEntity
{
    if ([otherEntity isKindOfClass:[Unit class]])
    {
        [(Unit *)otherEntity kill];
    }
    else
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"What the.. targets aren't supposed to interact with anything other than units."];
    }
}
@end
