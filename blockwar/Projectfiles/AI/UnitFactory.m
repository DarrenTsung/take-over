//
//  Factory.m
//  takeover
//
//  Created by Darren Tsung on 1/22/14.
//
//

#import "UnitFactory.h"
#import "EnemyAI.h"
#import "GameModel.h"

#define PADDING 10.0f

#define PROBABILITY_LENGTH 20

@implementation UnitFactory

-(id)initWithUnitToCopy:(Unit *)copyUnit andFactoryProperties:(NSDictionary *)properties andGameModel:(GameModel *)theModel
{
    if ((self = [super init]))
    {
        copyUnit_ = copyUnit;
        for (NSInteger i=0; i<PROBABILITY_LENGTH; i++)
        {
            probabilities_[i] = 1/PROBABILITY_LENGTH;
        }
        
        waveSize = [[properties objectForKey:@"waveSize"] floatValue];
        rowSize = [[properties objectForKey:@"rowSize"] floatValue];
        
        waveTimer = [[properties objectForKey:@"waveTimer"] floatValue];
        
        waveConsecutiveCount = 0;
        maxConsecutiveWaves = [[properties objectForKey:@"maxConsecutiveWaves"] intValue];
        
        probabilityWaveDelay = [[properties objectForKey:@"probabilityWaveDelay"] floatValue];
        waveDelay = [[properties objectForKey:@"waveDelay"] floatValue];
        
        model = theModel;
        
        // add delay to initial wave
        spawnTimer = waveDelay + 0.4f + ((arc4random()%5)/10.0f);
    }
    return self;
}

-(void) spawnWave
{
    int x = 0;
    int counter = 0;
    CGPoint spawnPoint = CGPointMake(575, arc4random()%(int)(model->playHeight - ((rowSize - 1)*PADDING + [copyUnit_ height])) + 10.0f);
    
    while(x < waveSize)
    {
        int offset = (counter%2 == 1) ? 5.0f : 0.0f;
        for(int i=0; i<rowSize; i++)
        {
            CGPoint lesserPoint = CGPointMake(spawnPoint.x+(PADDING*counter), spawnPoint.y + PADDING*i + offset);
            [self createUnitAtPoint:lesserPoint];
            x++;
        }
        //NSLog(@"added a row! offset %d", counter%2);
        counter++;
    }
}

-(void) update:(ccTime)delta
{
    if (spawnTimer > 0.0f)
    {
        spawnTimer -= delta;
    }
    else
    {
        if (waveConsecutiveCount < maxConsecutiveWaves)
        {
            // send enemy wave 
            [self spawnWave];
            spawnTimer = waveTimer;
            // p of the time, add 3 seconds to the next timer to space it out
            if ((arc4random_uniform(10)/10.0f) <= probabilityWaveDelay)
            {
                spawnTimer += waveDelay;
                waveConsecutiveCount = 0;
            }
            waveConsecutiveCount++;
        }
        else
        {
            spawnTimer += waveDelay;
            waveConsecutiveCount = 0;
        }
    }
}

-(void) createUnitAtPoint:(CGPoint)pos
{
    Unit *newUnit = [copyUnit_ UnitWithPosition:pos];
    [model insertEntity:newUnit intoSortedArrayWithName:@"enemy"];
}

-(void) reset
{
    spawnTimer = waveTimer;
}

@end
