//
//  Enemy_AI.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "Enemy_AI.h"
#import "Germ.h"

@implementation Enemy_AI

-(id) initWithReferenceToEnemyArray:(NSMutableArray *)army_array
{
    if((self = [super init]))
    {
        army = army_array;
        color = ccc4f(0.3f, 0.5f, 0.9f, 1.0f);
        wave_size = 5;
    }
    return self;
}

-(void) spawnWave
{
    for(int x=0; x<wave_size; x++)
    {
        [army addObject:[[Germ alloc] initWithPosition:CGPointMake(570, arc4random()%200 + 50) andColor:color andSize:CGSizeMake(15.0f, 15.0f) andSpeed:25.0f andIsOpponents:YES]];
    }
}

@end
