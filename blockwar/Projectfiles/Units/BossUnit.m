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

-(void) removeAndCleanup
{
    [((GameLayer *)[self parent]) endGameWithWinState:@"player"];
    [super removeAndCleanup];
    
}

@end
