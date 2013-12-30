//
//  GameLayer.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//  VIEW / CONTROLLER
//

#import "GameLayer.h"
#import "Unit.h"
#import "Blocker.h"
#import "EnemyAI.h"
#import "HealthBar.h"
#import "RegeneratableBar.h"
#import "SuperUnit.h"
#import "GameModel.h"
#import "WinLayer.h"
#import "LoseLayer.h"
#import "StartMenuLayer.h"
#import "LevelSelectLayer.h"

GameModel *model;

NSMutableArray *unitsToBeDeleted;
NSMutableArray *particleArray;

CGFloat touchIndicatorRadius;
CGPoint touchIndicatorCenter;
CGPoint touchStartPoint;
ccColor4F touchIndicatorColor;
#define SPAWN_SIZE 3
#define UNIT_COST 12
// super units cost 6 times what regular units cost
#define SUPER_UNIT_MULTIPLIER 6


CGSize screenBounds;
EnemyAI *theEnemy;

#define BAR_PADDING 10.0f

CGFloat currentLevel;
CGFloat currentWorld;

CGFloat bossSpawnTimer = 0.0f;
bool bossExists = false;
bool boss = false;

RegeneratableBar *playerResources;

bool isDone = FALSE;
CGFloat resetTimer = 0.0f;
#define RESET_TIME 3.0f;

#define UPDATE_INTERVAL 0.03f
#define UNIT_PADDING 20.0f

#define TOUCH_RADIUS_MAX 53.0f
#define TOUCH_RADIUS_MIN 40.0f
#define TOUCH_DAMAGE_RADIUS_MIN 56.0f
#define TOUCH_DAMAGE_RADIUS_MAX 66.0f
#define TOUCH_DAMAGE 2.0f

NSString *winState;
bool winFlag = false;

bool bombAvaliable = true;
#define BOMB_RECHARGE_RATE 3.0f
CGFloat bombTimer = 3.0f;


@interface GameLayer()

-(CGSize) returnScreenBounds;

@end



@implementation GameLayer

-(id) init
{
    if (self = [self initWithWorld:1 andLevel:1])
    {
    }
    return self;
}

-(id) initWithWorld:(int)world andLevel:(int)level
{
    if ((self = [super initWithColor:ccc4(1.0f,1.0f,1.0f,1.0f)]))
    {
        NSLog(@"Game initializing...");
        winState = nil;
        isDone = false;
        
        currentWorld = world;
        currentLevel = level;
        NSString *levelPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"World%d_Level%d", world, level] ofType:@"plist"];
        NSDictionary *levelProperties = [NSDictionary dictionaryWithContentsOfFile:levelPath];
        NSString *AIName = [levelProperties objectForKey:@"AIName"];

        // returns screenBounds flipped automatically (since we're in landscape mode)
        screenBounds = [self returnScreenBounds];
        NSLog(@"The screen width and height are (%f, %f)", screenBounds.width, screenBounds.height);
        playHeight = 10.2 * screenBounds.height/12.2;
        
        // touch_area is the player's spawning area
        touchArea.origin = CGPointMake(0.0f, 0.0f);
        touchArea.size = CGSizeMake(screenBounds.width/7, playHeight);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"russianframes.plist"];
        CCSpriteBatchNode *russianSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"russianframes.png"];
        [self addChild:russianSpriteSheet];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bossrussianframes.plist"];
        CCSpriteBatchNode *bossrussianSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"bossrussianframes.png"];
        [self addChild:bossrussianSpriteSheet];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"zombieframes.plist"];
        CCSpriteBatchNode *zombieSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"zombieframes.png"];
        [self addChild:zombieSpriteSheet];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"superzombieframes.plist"];
        CCSpriteBatchNode *superzombieSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"superzombieframes.png"];
        [self addChild:superzombieSpriteSheet];
        
        // model controls and models all the germs
        model = [[GameModel alloc] initWithReferenceToViewController:self andReferenceToLevelProperties:levelProperties];
        
        // theEnemy.. oo ominous!
        theEnemy = [[EnemyAI alloc] initAIType:AIName withReferenceToGameModel:model andViewController:self andPlayHeight:playHeight];
        // now give model a pointer to theEnemy
        [model setReferenceToEnemyAI:theEnemy];
        [self addChild:model];
        
        // Resource Bars
        enemyHP = [[HealthBar node] initWithOrigin:CGPointMake(screenBounds.width - BAR_PADDING, screenBounds.height - 20.0f) andOrientation:@"Left" andColor:ccc4f(0.9f, 0.3f, 0.4f, 1.0f) withLinkTo:&model->enemyHP];
        playerHP = [[HealthBar node] initWithOrigin:CGPointMake(BAR_PADDING, screenBounds.height - 20.0f) andOrientation:@"Right" andColor:ccc4f(107.0f/255.0f, 214.0f/255.0f, 119.0f/255.0f, 1.0f) withLinkTo:&model->playerHP];
        playerResources = [[RegeneratableBar node] initWithOrigin:CGPointMake(BAR_PADDING, screenBounds.height - 35.0f) andOrientation:@"Right" andColor:ccc4f(151.0f/255.0f, 176.0f/255.0f, 113.0f/255.0f, 1.0f) withLinkTo:&model->playerResources];
        [self addChild:enemyHP];
        [self addChild:playerHP];
        [self addChild:playerResources];
    }
    
    [self schedule:@selector(nextFrame) interval:UPDATE_INTERVAL]; // updates 30 frames a second (hopefully?)
    [self scheduleUpdate];
    return self;
}

-(void) onEnter
{
    [super onEnter];
    CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
    background.position = ccp( 280, 160 );
        
    [self addChild: background z:-1];
}

-(void) draw
{
    ccColor4F area_color = ccc4f(0.3f, 0.3f, 0.3f, 0.5f);
    ccDrawSolidRect(touchArea.origin, CGPointMake(touchArea.size.width + touchArea.origin.x, touchArea.size.height + touchArea.origin.y), area_color);
    
    if (touchIndicatorRadius > 30.0f)
    {
        ccDrawColor4F(touchIndicatorColor.r, touchIndicatorColor.g, touchIndicatorColor.b, touchIndicatorColor.a);
        ccDrawCircle(touchIndicatorCenter, touchIndicatorRadius, CC_DEGREES_TO_RADIANS(60), 16, NO);
    }
    
    if (bombAvaliable)
    {
        ccDrawSolidRect(CGPointMake(170.0f, screenBounds.height - 20.0f), CGPointMake(180.0f, screenBounds.height - 30.0f), ccc4f(0.7f, 0.7f, 0.7f, 1.0f));
    }
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput* input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    if (!isDone)
    {
        if (!bombAvaliable)
        {
            bombTimer -= delta;
            if (bombTimer <= 0.0f)
            {
                bombAvaliable = true;
            }
        }
        
        bool inTouchArea = CGRectContainsPoint(touchArea, pos);
        if(input.anyTouchBeganThisFrame)
        {
            if (inTouchArea)
            {
                touchStartPoint = pos;
                touchIndicatorCenter = pos;
                touchIndicatorRadius = TOUCH_RADIUS_MIN;
                touchIndicatorColor = ccc4f(1.0f, 1.0f, 1.0f, 1.0f);
            }
            else
            {
                if (bombAvaliable)
                {
                    touchStartPoint = pos;
                    touchIndicatorCenter = pos;
                    touchIndicatorRadius = TOUCH_DAMAGE_RADIUS_MIN;
                    touchIndicatorColor = ccc4f(1.0f, 0.4f, 0.6f, 1.0f);
                    bombTimer = BOMB_RECHARGE_RATE;
                    bombAvaliable = false;
                }
            }
            
            // DEMO CODE : RESTART (WIN SCREEN -> MENU LAYER) IF YOU PRESS TOP RIGHT OF SCREEN
            if (pos.x > (6*screenBounds.width/7) && pos.y > (6*screenBounds.height/7))
            {
                [[CCDirector sharedDirector] replaceScene:
                    [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[StartMenuLayer alloc] init]]];
            }
        }
        // second part of the conditional fixes the bug where kkinput doesn't detect an end of the touch near the bottom
        else if(input.anyTouchEndedThisFrame || (!input.touchesAvailable && touchIndicatorRadius >= TOUCH_RADIUS_MIN))
        {
            /*
            CGFloat xChange = pos.x - touchStartPoint.x;
            CGFloat yChange = pos.y - touchStartPoint.y;
            CGFloat distanceChange = sqrt((xChange*xChange) + (yChange*yChange));
            // if distance between two points is less than 30.0f
             NSLog(@"xChange, yChange = (%f, %f) :: distanceChange = %f!", xChange, yChange, distanceChange);
            */
            // BLOCKERS DEPRECATED FOR DEMO \\
            //if (distanceChange < 30.0f)
            if (inTouchArea && touchIndicatorRadius >= TOUCH_RADIUS_MIN)
            {
                // spawn SuperGerm if radius is greater than max (and fluctuating)
                if (touchIndicatorRadius >= TOUCH_RADIUS_MAX && [playerResources getCurrentValue] > SUPER_UNIT_MULTIPLIER*UNIT_COST)
                {
                    SuperUnit *unit = [[SuperUnit alloc] initWithPosition:pos];
                    [model insertUnit:unit intoSortedArrayWithName:@"playerUnits"];
                }
                else if ([playerResources getCurrentValue] > SPAWN_SIZE*UNIT_COST)
                {
                    NSMutableArray *positions_to_be_spawned = [[NSMutableArray alloc] init];
                    // generate units
                    for (int i = 0; i < SPAWN_SIZE; i++)
                    {
                        CGPoint random_pos;
                        bool not_near = false;
                        while (!not_near)
                        {
                            not_near = true;
                            random_pos = CGPointMake(pos.x + arc4random()%(int)TOUCH_RADIUS_MAX - 25, pos.y + arc4random() % (int)TOUCH_RADIUS_MAX - 25);
                            for (NSValue *o_pos in positions_to_be_spawned)
                            {
                                CGPoint other_pos = [o_pos CGPointValue];
                                CGFloat xDist = other_pos.x - random_pos.x;
                                CGFloat yDist = other_pos.y - random_pos.y;
                                // if distance between two points is less than padding
                                if (sqrt((xDist*xDist) + (yDist*yDist)) < UNIT_PADDING)
                                {
                                    // too close to another point, generate again
                                    not_near = false;
                                    break;
                                }
                            }
                        }
                        [positions_to_be_spawned addObject:[NSValue valueWithCGPoint:random_pos]];
                    }
                    for (NSValue *position in positions_to_be_spawned)
                    {
                        Unit *unit = [[Unit alloc] initUnit:@"zombie" withOwner:@"Player" AndPosition:[position CGPointValue]];
                        [model insertUnit:unit intoSortedArrayWithName:@"playerUnits"];
                    }
                }
            }
            // BLOCKERS DEPRECATED FOR DEMO \\
            // if we make a vertical sweep, spawn blockers (slow moving units that don't get pushed back)
            /*
            else if (abs(xChange) < 30.0f && abs(yChange) > 40.0f)
            {
                // blockers have a 1.3 size modifier
                int numUnits = yChange/(UNIT_PADDING*1.3);
                if ([playerResources getCurrentValue] > numUnits*UNIT_COST*1.3)
                {
                    if (numUnits > 0.0f)
                    {
                        // don't let the player spawn more than 5 blockers
                        if (numUnits > 5)
                        {
                            numUnits = 5;
                        }
                        for (int i=0; i<numUnits; i++)
                        {
                            [model insertUnit:[[Blocker alloc] initWithPosition:CGPointMake(touchStartPoint.x + arc4random()%5, touchStartPoint.y + i*(UNIT_PADDING*1.3))] intoSortedArrayWithName:@"playerUnits"];
                        }
                        [playerResources decreaseValueBy:numUnits*UNIT_COST*1.3];
                    }
                    else
                    {
                        // don't let the player spawn more than 5 blockers
                        if (numUnits < -5)
                        {
                            numUnits = -5;
                        }
                        for (int i=0; i>numUnits; i--)
                        {
                            [model insertUnit:[[Blocker alloc] initWithPosition:CGPointMake(touchStartPoint.x + arc4random()%5, touchStartPoint.y + i*(UNIT_PADDING*1.3))] intoSortedArrayWithName:@"playerUnits"];
                        }
                        [playerResources decreaseValueBy:abs(numUnits)*UNIT_COST*1.3];
                    }
                }
            } */
            else
            {
                // MIN = 0.0f || MAX = 1.0f
                CGFloat percentCharged = (touchIndicatorRadius - TOUCH_DAMAGE_RADIUS_MIN) / (TOUCH_DAMAGE_RADIUS_MAX - TOUCH_DAMAGE_RADIUS_MIN);
                // NSLog(@"percent charged %f", percentCharged);
                // percentCharged = 0.0f -> damagePercentage = 0.8 || percentCharged = 1.0f -> damagePercentage = 1.2
                CGFloat damagePercentage = (0.4f * percentCharged) + 0.8;
                // NSLog(@"damagePercentage %f || damageDone %f", damagePercentage, (damagePercentage * TOUCH_DAMAGE));
                [model dealDamage:(damagePercentage * TOUCH_DAMAGE) toUnitsInDistance:touchIndicatorRadius ofPoint:touchIndicatorCenter];
            }
            touchIndicatorRadius = 0.0f;
            touchStartPoint = CGPointMake(0.0f, 0.0f);
        }
        else if(input.touchesAvailable)
        {
            if (pos.y < playHeight)
            {
                if (touchIndicatorRadius < TOUCH_DAMAGE_RADIUS_MIN)
                {
                    CGFloat xChange = pos.x - touchStartPoint.x;
                    CGFloat yChange = pos.y - touchStartPoint.y;
                    CGFloat distanceChange = sqrt((xChange*xChange) + (yChange*yChange));
                    // BLOCKERS DEPRECATED FOR DEMO \\
                    //if (distanceChange < 30.f)
                    if (true)
                    {
                        if (inTouchArea)
                        {
                            touchIndicatorCenter = pos;
                        }
                        else    // only update the up-down movement if pos is out of bounds
                        {
                            touchIndicatorCenter.y = pos.y;
                        }
                        if (touchIndicatorRadius < TOUCH_RADIUS_MAX)
                        {
                            touchIndicatorRadius += 0.33f;
                        }
                        else
                        {
                            touchIndicatorRadius = TOUCH_RADIUS_MAX + arc4random()%3;
                        }
                    }
                }
                else
                {
                    touchIndicatorCenter = pos;
                    if (touchIndicatorRadius < TOUCH_DAMAGE_RADIUS_MAX)
                    {
                        touchIndicatorRadius += 0.33f;
                    }
                    else
                    {
                        touchIndicatorRadius = TOUCH_DAMAGE_RADIUS_MAX + arc4random()%7;
                        CGFloat randomBetweenOne = ((CGFloat)(arc4random()%5 + 1.0f) / 5.0f);
                        touchIndicatorColor = ccc4f(1.0f, randomBetweenOne*0.4f + 0.1f, randomBetweenOne*0.5f + 0.15f, 1.0f);
                    }
                }
            }
            else
            {
                touchIndicatorRadius = 0.0f;
            }
        }
    }
 
    if (!isDone)
    {
        [playerHP updateAnimation:delta];
        [enemyHP updateAnimation:delta];
        [playerResources updateAnimation:delta];
    }
}

-(void) nextFrame
{
    if (!isDone)
    {
        [playerHP update:UPDATE_INTERVAL];
        [enemyHP update:UPDATE_INTERVAL];
        [playerResources update:UPDATE_INTERVAL];
        
        [model update:UPDATE_INTERVAL];
        
        [theEnemy update:UPDATE_INTERVAL];
        
        // after units are done spawning / moving, check for collisions
        [model checkForCollisionsAndRemove];
    }
}

-(void) reset
{
    [playerHP resetValueToMax];
    [enemyHP resetValueToMax];
    [playerResources resetValueToMax];
    [model reset];
    [theEnemy reset];
    
    touchIndicatorRadius = 0.0f;
    
    isDone = false;
    winFlag = false;
    boss = false;
    
    NSLog(@"resetting with winState: %@", winState);
    
    if ([winState isEqualToString:@"player"])
    {
        // unlock the next level
        NSInteger *nextLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelUnlocked"] + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:nextLevel forKey:@"levelUnlocked"];
        // go back to the level select screen
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[LevelSelectLayer alloc] init]]];
    }
    else if ([winState isEqualToString:@"enemy"])
    {
        // reset the level
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[GameLayer alloc] initWithWorld:currentWorld andLevel:currentLevel]]];
    }
    else if ([winState isEqualToString:@"win"])
    {
        [[CCDirector sharedDirector] replaceScene:
            [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[WinLayer alloc] init]]];
    }
    else if ([winState isEqualToString:@"lose"])
    {
        [[CCDirector sharedDirector] replaceScene:
            [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[LoseLayer alloc] init]]];
    }
    winState = nil;
}

// returns the screen bounds, flipped since we're working in landscape mode
-(CGSize) returnScreenBounds
{
    CGSize screenBounds = [[UIScreen mainScreen] bounds].size;
    // flip the height and width since we're in landscape mode
    CGFloat temp = screenBounds.height;
    screenBounds.height = screenBounds.width;
    screenBounds.width = temp;
    return screenBounds;
}

-(void) endGameWithWinState:(NSString *)theWinState
{
    NSLog(@"Win state: %@!", theWinState);
    winState = theWinState;
    isDone = true;
    [playerHP stopShake];
    [enemyHP stopShake];
    
    [self scheduleOnce:@selector(reset) delay:3.0f];
}



@end
