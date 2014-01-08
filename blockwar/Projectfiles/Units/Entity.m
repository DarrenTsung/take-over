//
//  Entity.m
//  takeover
//
//  Created by Darren Tsung on 1/7/14.
//
//

#import "Entity.h"

@implementation Entity

-(bool) isCollidingWith:(Entity *)otherEntity
{
    if (CGRectIntersectsRect([self boundingBox], [otherEntity boundingBox]))
    {
        return YES;
    }
    return NO;
}

-(CGFloat) width
{
    return [self boundingBox].size.width;
}

-(CGFloat) height
{
    return [self boundingBox].size.height;
}

-(void) actOnEntity:(Entity *)otherEntity
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override actOnEntity in a subclass"];
}

-(void) removeAndCleanup
{
    if ([self parent])
    {
        [[self parent] removeChild:self cleanup:YES];
    }
}

@end
