//
//  EnemyAI.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "EnemyAI.h"
#import "Germ.h"
#import "GermFactory.h"

#define PADDING 20.0f
#define UNIT_SIZE_Y 15.0f

@implementation EnemyAI

-(id) initWithReferenceToGermFactory:(GermFactory *)germMaster
{
    if((self = [super init]))
    {
        spawner = germMaster;
        color = ccc4f(0.3f, 0.5f, 0.9f, 1.0f);
        waveSize = 24;
        rowSize = 8;
    }
    return self;
}

-(void) spawnWaveWithPlayHeight:(CGFloat)playHeight
{
    int x = 0;
    int counter = 0;
    CGPoint spawnPoint = CGPointMake(575, arc4random()%(int)(playHeight - ((rowSize - 1)*PADDING + UNIT_SIZE_Y) + 10.0f));
    
    while(x < waveSize)
    {
        int offset = (counter%2 == 1) ? 5.0f : 0.0f;
        for(int i=0; i<rowSize; i++)
        {
            CGPoint lesserPoint = CGPointMake(spawnPoint.x+(PADDING*counter), spawnPoint.y + PADDING*i + offset);
            [spawner insertGerm:[[Germ alloc] initWithPosition:lesserPoint andIsOpponents: YES] intoSortedArrayWithName:@"enemyUnits"];
            x++;
        }
        //NSLog(@"added a row! offset %d", counter%2);
        counter++;
    }
}

@end
