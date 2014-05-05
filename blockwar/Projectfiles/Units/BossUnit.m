//
//  BossUnit.m
//  blockwar
//
//  Created by Darren Tsung on 12/6/13.
//
//

#import "BossUnit.h"
#import "GameLayer.h"

#define BOUNDING_RECT_MODIFIER 1.5f

@implementation BossUnit

-(id) initWithPosition:(CGPoint)pos
{
    if ((self = [super initWithPosition:pos]))
    {
        doingSpecialAction_ = false;
        
        CGFloat delay = arc4random()%2 + 5.2f;
        [self scheduleOnce:@selector(doSpecialAction) delay:delay];
    }
    return self;
}

-(void) removeAndCleanup
{
    [((GameLayer *)[self parent]) endGameWithWinState:@"player"];
    [super removeAndCleanup];
}

-(void) computeFrame:(ccTime)delta
{
    if (!doingSpecialAction_)
    {
        [super computeFrame:delta];
    }
}

-(void) doSpecialAction
{
    
}

@end
