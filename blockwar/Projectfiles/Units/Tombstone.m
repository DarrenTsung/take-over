//
//  Tombstone.m
//  takeover
//
//  Created by Darren Tsung on 2/17/14.
//
//

#import "Tombstone.h"

#define BOUNDING_RECT_MODIFIER 1.1f

@implementation Tombstone

-(id)initWithPosition:(CGPoint)pos
{
    if ((self = [super initWithPosition:pos]))
    {
        origin = pos;
        
        // choose one of two random tombstone sprites
        currentFrame = arc4random_uniform(2);
        
        // 1 <= scalefactor <= 1.4
        CGFloat scaleFactor = arc4random_uniform(3) / 10.0f + 1.0f;
        [self setScale:scaleFactor];
        
        name = @"tombstone";
        owner = @"player";
        
        health = 20.0f;

        [self finishInit];
        [whiteSprite setScale:scaleFactor];
    }
    return self;
}

// override update so that no frame is computed or anything
-(void)update:(ccTime) delta
{
}

-(void) actOnEntity:(Entity *)otherEntity
{
    if ([otherEntity isKindOfClass:[Unit class]])
    {
        Unit *enemyUnit = (Unit *)otherEntity;
        [enemyUnit hitFor:0.0f];
        
        if ([otherEntity isKindOfClass:[BossUnit class]])
        {
            [((GameLayer *)[self parent])->shaker shakeWithShakeValue:5 forTime:0.7f];
        }
    }
}

@end
