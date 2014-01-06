//
//  Blocker.m
//  blockwar
//
//  Created by Darren Tsung on 11/6/13.
//
//

#import "Blocker.h"

@implementation Blocker

-(id) initWithPosition:(CGPoint)pos
{
    if ((self = [super initWithPosition:pos andName:@"zombie"]))
    {
        // blockers are healthier, bigger and slower. they do less damage but also get pushed back less
        health *= 2.8f;
        [self setDamage:damage*0.35f];
        [self setMaxVelocity:maxVelocity*0.5];
        pushBack *= 0.3f;
        size = CGSizeMake(size.width*1.3f, size.height*1.3);
    }
    return self;
}


@end
