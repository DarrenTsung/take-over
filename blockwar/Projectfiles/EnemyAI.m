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

-(id) initWithReferenceToEnemyArray:(NSMutableArray *)army_array
{
    if((self = [super init]))
    {
        army = army_array;
        color = ccc4f(0.3f, 0.5f, 0.9f, 1.0f);
        wave_size = 8;
    }
    return self;
}

-(void) spawnWave
{
    int x;
    for(x=0; x<wave_size/2; x++)
    {
        [army addObject:[[Germ alloc] initWithPosition:CGPointMake(570, arc4random()%200 + 50) andIsOpponents:YES]];
    }
    for(; x<wave_size; x++)
    {
        [army addObject:[[Germ alloc] initWithPosition:CGPointMake(580, arc4random()%200 + 50) andIsOpponents:YES]];
    }
}

@end
