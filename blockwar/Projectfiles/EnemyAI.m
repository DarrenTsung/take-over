//
//  EnemyAI.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "EnemyAI.h"
#import "Germ.h"

@implementation EnemyAI

-(id) initWithReferenceToEnemyArray:(NSMutableArray *)armyArray
{
    if((self = [super init]))
    {
        army = armyArray;
        color = ccc4f(0.3f, 0.5f, 0.9f, 1.0f);
        waveSize = 8;
    }
    return self;
}

-(void) spawnWave
{
    int x;
    CGPoint spawnPoint = CGPointMake(575, arc4random()%200 + 25);
    for(x = 0; x < waveSize/2; x++)
    {
        CGPoint lesserPoint = CGPointMake(spawnPoint.x, spawnPoint.y + 20.0f*x);
        [army addObject:[[Germ alloc] initWithPosition:lesserPoint andIsOpponents: YES]];
    }
    for(; x < waveSize; x++)
    {
        CGPoint lesserPoint = CGPointMake(spawnPoint.x + 20.0f, spawnPoint.y + 20.0f*(x-waveSize/2 + 0.5f));
        [army addObject:[[Germ alloc] initWithPosition:lesserPoint andIsOpponents: YES]];
    }
}

@end
