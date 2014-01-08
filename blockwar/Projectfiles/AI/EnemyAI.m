//
//  EnemyAI.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "EnemyAI.h"
#import "Unit.h"
#import "GameModel.h"
#import "GameLayer.h"
#import "BossUnit.h"

#define PADDING 20.0f
#define UNIT_SIZE_Y 15.0f

#define ARC4RANDOM_MAX 0x100000000

@implementation EnemyAI

-(id) initAIType:(NSString *)theType withReferenceToGameModel:(GameModel *)theModel andViewController:(GameLayer *)theViewController andPlayHeight:(CGFloat)thePlayHeight
{
    if((self = [super init]))
    {
        NSString *AIpath = [[NSBundle mainBundle] pathForResource:theType ofType:@"plist"];
        NSDictionary *AIproperties = [NSDictionary dictionaryWithContentsOfFile:AIpath];
        
        model = theModel;
        waveSize = [[AIproperties objectForKey:@"waveSize"] floatValue];
        rowSize = [[AIproperties objectForKey:@"rowSize"] floatValue];
        
        waveTimer = [[AIproperties objectForKey:@"waveTimer"] floatValue];
    
        waveConsecutiveCount = 0;
        maxConsecutiveWaves = [[AIproperties objectForKey:@"maxConsecutiveWaves"] intValue];
        
        probabilityWaveDelay = [[AIproperties objectForKey:@"probabilityWaveDelay"] floatValue];
        waveDelay = [[AIproperties objectForKey:@"waveDelay"] floatValue];
        
        playHeight = thePlayHeight;
        
        // add delay to initial wave
        spawnTimer = waveTimer + 0.9f;
        viewController = theViewController;
    }
    return self;
}

-(void) spawnWave
{
    int x = 0;
    int counter = 0;
    CGPoint spawnPoint = CGPointMake(575, arc4random()%(int)(playHeight - ((rowSize - 1)*PADDING + UNIT_SIZE_Y)) + 10.0f);
    
    while(x < waveSize)
    {
        int offset = (counter%2 == 1) ? 5.0f : 0.0f;
        for(int i=0; i<rowSize; i++)
        {
            CGPoint lesserPoint = CGPointMake(spawnPoint.x+(PADDING*counter), spawnPoint.y + PADDING*i + offset);
            [model insertEntity:[[Unit alloc] initUnit:@"russian" withOwner:@"Opponent" AndPosition:lesserPoint] intoSortedArrayWithName:@"enemy"];
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
            // send enemy wave every 5 seconds
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

-(void) spawnBosswithProperties:(NSDictionary *)bossProperties
{
    Unit *theBoss;
    if ([[bossProperties objectForKey:@"name"] isEqualToString:@"russian"])
    {
        theBoss = [[BossUnit alloc] initBossWithPosition:CGPointMake(595, playHeight/2)];
    }
    [model insertEntity:theBoss intoSortedArrayWithName:@"enemy"];
    [theBoss setInvincibleForTime:0.4f];
    NSArray *layerColors = [bossProperties objectForKey:@"layerProperties"];
    NSInteger layerCount = [layerColors count];
    [viewController->enemyHP changeLinkTo:&theBoss->health with:layerCount layersWithColors:layerColors];
    [viewController->enemyHP loadingToMaxAnimationWithTime:1.7f];
}

-(void) reset
{
    spawnTimer = waveTimer;
}

@end
