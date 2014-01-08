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
#import "EnemyAI.h"
#import "HealthBar.h"
#import "RegeneratableBar.h"
#import "SuperUnit.h"
#import "GameModel.h"
#import "WinLayer.h"
#import "LoseLayer.h"
#import "StartMenuLayer.h"
#import "LevelSelectLayer.h"
#import "NodeShaker.h"
#import "TouchHandler.h"
#import "RectTarget.h"

GameModel *model;

NSMutableArray *unitsToBeDeleted;
NSMutableArray *particleArray;


CGSize screenBounds;
EnemyAI *theEnemy;

#define BAR_PADDING 10.0f

CGFloat currentLevel;
CGFloat currentWorld;

CGFloat bossSpawnTimer = 0.0f;
bool bossExists = false;
bool boss = false;

RegeneratableBar *playerResources;

CGFloat resetTimer = 0.0f;
#define RESET_TIME 3.0f;

#define UPDATE_INTERVAL 0.03f
#define UNIT_PADDING 20.0f

NSString *winState;
bool winFlag = false;

bool bombAvaliable = true;
#define BOMB_RECHARGE_RATE 3.0f
CGFloat bombTimer = 3.0f;

TouchHandler *myTouchHandler;

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
    if ((self = [super initWithColor:ccc4(0.85f,0.8f,0.7f,1.0f)]))
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
        
        [self loadSpriteSheets];
        
        // model controls and models all the germs
        model = [[GameModel alloc] initWithReferenceToViewController:self andReferenceToLevelProperties:levelProperties];
        
        // theEnemy.. oo ominous!
        theEnemy = [[EnemyAI alloc] initAIType:AIName withReferenceToGameModel:model andViewController:self andPlayHeight:playHeight];
        // now give model a pointer to theEnemy
        [model setReferenceToEnemyAI:theEnemy];
        [self addChild:model];
        
        [self setUpResourceBars];
        
        // my shaker
        shaker = [[NodeShaker alloc] initWithReferenceToNode:self];
        [self addChild:shaker];
        
        // spawnArea is the player's spawning area
        spawnArea.origin = CGPointZero;
        spawnArea.size = CGSizeMake(screenBounds.width/7, playHeight);
        RectTarget *playerTarget = [[RectTarget alloc] initWithRectLink:&spawnArea andLink:&model->playerHP];
        [model insertEntity:playerTarget intoSortedArrayWithName:@"player"];
        
        // battleArea is the area of the battle
        battleArea.origin = CGPointMake(screenBounds.width/7, 0);
        battleArea.size = CGSizeMake(6*screenBounds.width/7, playHeight);
        
        rightSide = CGRectMake(568, 0, 60, 320);
        RectTarget *enemyTarget = [[RectTarget alloc] initWithRectLink:&rightSide andLink:&model->enemyHP];
        [model insertEntity:enemyTarget intoSortedArrayWithName:@"enemy"];
        
        // see if we need to play the tapAnimation
        NSArray *levelTapAnimationProperties = [levelProperties objectForKey:@"tapAnimationProperties"];
        if (levelTapAnimationProperties)
        {
            CGFloat animationX = [[levelTapAnimationProperties objectAtIndex:0] floatValue];
            CGFloat animationY = [[levelTapAnimationProperties objectAtIndex:1] floatValue];
            CGFloat timeToPlay = [[levelTapAnimationProperties objectAtIndex:2] floatValue];
            [self setUpTapAnimationAtPosition:ccp(animationX, animationY) inTime:timeToPlay];
        }
        
        myTouchHandler = [[TouchHandler alloc] initWithReferenceToViewController:self andReferenceToGameModel:model];
    }
    
    [self schedule:@selector(nextFrame) interval:UPDATE_INTERVAL]; // updates 30 frames a second (hopefully?)
    [self scheduleUpdate];
    return self;
}

-(void) setUpTapAnimationAtPosition:(CGPoint)pos inTime:(ccTime)time
{
    NSMutableArray *tapIndicatorFrames = [NSMutableArray array];
    NSString *prefix = @"tap_indicator_";
    for (int i=1; i<=17; i++)
    {
        [tapIndicatorFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"%@%d.png", prefix, i]]];
    }
    CCAnimation *tapAnimation = [CCAnimation animationWithSpriteFrames:tapIndicatorFrames delay:1/20.0f];
    CCAction *playTapIndicator = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:tapAnimation] times:1];
    
    tapIndicatorSprite = [[IndicatorSprite alloc] initWithSpriteFrame:@"tap_indicator_1.png" andPosition:pos andAction:playTapIndicator andTarget:spawnArea];
    [self scheduleOnce:@selector(addTapIndicatorToSelf) delay:time];
}

-(void) addTapIndicatorToSelf
{
    [self addChild:tapIndicatorSprite z:321];
    isDone = true;
}

-(void) setUpResourceBars
{
    // Resource Bars
    enemyHP = [[HealthBar node] initWithOrigin:CGPointMake(screenBounds.width - BAR_PADDING, screenBounds.height - 20.0f) andOrientation:@"Left" andColor:ccc4f(0.9f, 0.3f, 0.4f, 1.0f) withLinkTo:&model->enemyHP];
    playerHP = [[HealthBar node] initWithOrigin:CGPointMake(BAR_PADDING, screenBounds.height - 20.0f) andOrientation:@"Right" andColor:ccc4f(107.0f/255.0f, 214.0f/255.0f, 119.0f/255.0f, 1.0f) withLinkTo:&model->playerHP];
    playerResources = [[RegeneratableBar node] initWithOrigin:CGPointMake(BAR_PADDING, screenBounds.height - 35.0f) andOrientation:@"Right" andColor:ccc4f(151.0f/255.0f, 176.0f/255.0f, 113.0f/255.0f, 1.0f) withLinkTo:&model->playerResources];
    [self addChild:enemyHP];
    [self addChild:playerHP];
    [self addChild:playerResources];
}

-(void) loadSpriteSheets
{
    // unit sprite sheets
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
    
    // overlay sprite sheets
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"win_overlay_frames.plist"];
    CCSpriteBatchNode *winOverlaySpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"win_overlay_frames.png"];
    [self addChild:winOverlaySpriteSheet];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lose_overlay_frames.plist"];
    CCSpriteBatchNode *loseOverlaySpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"lose_overlay_frames.png"];
    [self addChild:loseOverlaySpriteSheet];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tap_indicator_frames.plist"];
    CCSpriteBatchNode *tapIndicatorSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"tap_indicator_frames.png"];
    [self addChild:tapIndicatorSpriteSheet];
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
    ccDrawSolidRect(spawnArea.origin, CGPointMake(spawnArea.size.width + spawnArea.origin.x, spawnArea.size.height + spawnArea.origin.y), area_color);

    if (bombAvaliable)
    {
        ccDrawSolidRect(CGPointMake(170.0f, screenBounds.height - 20.0f), CGPointMake(180.0f, screenBounds.height - 30.0f), ccc4f(0.7f, 0.7f, 0.7f, 1.0f));
    }
}

-(void) update:(ccTime)delta
{
    [playerHP updateAnimation:delta];
    [enemyHP updateAnimation:delta];
    [playerResources updateAnimation:delta];

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
        [model checkForCollisions];
        
        [model removeDeadUnitsAndCheckWinState];
    }
}

-(void) reset
{
    [playerHP resetValueToMax];
    [enemyHP resetValueToMax];
    [playerResources resetValueToMax];
    [model reset];
    [theEnemy reset];
    [myTouchHandler reset];
    
    isDone = false;
    winFlag = false;
    boss = false;
    
    NSLog(@"resetting with winState: %@", winState);
    
    if ([winState isEqualToString:@"player"])
    {
        // go back to the level select screen
        LevelSelectLayer *levelSelect = [[LevelSelectLayer alloc] init];
        if (currentLevel == [[NSUserDefaults standardUserDefaults] integerForKey:@"levelUnlocked"])
        {
            [levelSelect scheduleOnce:@selector(unlockNextLevel) delay:0.5f];
        }
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)levelSelect]];
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
    
    if ([theWinState isEqualToString:@"player"] || [theWinState isEqualToString:@"win"])
    {
        [self playOverlay:@"win"];
    }
    else if ([theWinState isEqualToString:@"enemy"] || [theWinState isEqualToString:@"lose"])
    {
        [self playOverlay:@"lose"];
    }
    
    winState = theWinState;
    isDone = true;
    [playerHP stopShake];
    [enemyHP stopShake];
    
    [self scheduleOnce:@selector(reset) delay:4.0f];
}

-(void) playOverlay:(NSString *)overlayType
{
    NSMutableArray *overlayFrames = [NSMutableArray array];
    NSString *prefix;
    if ([overlayType isEqualToString:@"win"])
    {
        prefix = @"win_overlay_";
    }
    else if ([overlayType isEqualToString:@"lose"])
    {
        prefix = @"lose_overlay_";
    }
    
    for (int i=1; i<=14; i++)
    {
        [overlayFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"%@%d.png", prefix, i]]];
    }
    CCAnimation *overlayAnimation = [CCAnimation animationWithSpriteFrames:overlayFrames delay:1/20.0f];
    CCAction *playOverlay = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:overlayAnimation] times:1];
    
    CCSprite *overlaySprite = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"win_overlay_1.png"]];
    [overlaySprite setPosition:ccp(284, 160)];
    [self addChild:overlaySprite z:587];
    [overlaySprite runAction:playOverlay];
}


@end
