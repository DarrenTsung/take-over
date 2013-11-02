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
    for(x = 0; x < waveSize/2; x++)
    {
        [army addObject:[[Germ alloc] initWithPosition:CGPointMake(570, arc4random()%200 + 25) andIsOpponents: YES]];
    }
    for(; x < waveSize; x++)
    {
        [army addObject:[[Germ alloc] initWithPosition:CGPointMake(580, arc4random()%200 + 25) andIsOpponents: YES]];
    }
}

@end
