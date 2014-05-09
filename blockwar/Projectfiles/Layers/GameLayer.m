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
#import "RussianAI.h"

NSMutableArray *unitsToBeDeleted;
NSMutableArray *particleArray;


CGSize screenBounds;
EnemyAI *theEnemy;

#define BAR_PADDING 5.0f

int currentLevel;
RegionType currentRegion;

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
    if (self = [self initWithRegion:AFRICA andLevel:1])
    {
    }
    return self;
}

-(id) initWithRegion:(RegionType)region andLevel:(int)level
{
    if ((self = [super initWithColor:ccc4(0.85f,0.8f,0.7f,1.0f)]))
    {
        NSLog(@"Game initializing...");
        winState = nil;
        
        currentRegion = region;
        currentLevel = level;
        
        NSString *prefix;
        Class AIClass;
        if (region == AFRICA)
        {
            prefix = @"Africa";
        }
        else if (region == ASIA)
        {
            prefix = @"Asia";
        }
        else if (region == RUSSIA)
        {
            prefix = @"Russia";
            AIClass = [RussianAI class];
        }
        else if (region == AMERICA)
        {
            prefix = @"America";
        }
        NSString *levelPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_Level%d", prefix, level] ofType:@"plist"];
        NSDictionary *levelProperties = [NSDictionary dictionaryWithContentsOfFile:levelPath];
        NSString *AIName = [levelProperties objectForKey:@"AIName"];

        // returns screenBounds flipped automatically (since we're in landscape mode)
        screenBounds = [self returnScreenBounds];
        NSLog(@"The screen width and height are (%f, %f)", screenBounds.width, screenBounds.height);
        playHeight = 10.8 * screenBounds.height/12.2;
        
        [self loadSpriteSheets];
        
        // model controls and models all the germs
        model = [[GameModel alloc] initWithReferenceToViewController:self andReferenceToLevelProperties:levelProperties];
        
        // theEnemy.. oo ominous!
        theEnemy = [[AIClass alloc] initAIType:AIName withReferenceToGameModel:model andViewController:self andPlayHeight:playHeight];
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
        playerTarget = [[RectTarget alloc] initWithRectLink:&spawnArea andLink:&model->playerHP andLayer:self];
        [model insertEntity:playerTarget intoSortedArrayWithName:@"player"];
        
        // battleArea is the area of the battle
        battleArea.origin = CGPointMake(screenBounds.width/7, 0);
        battleArea.size = CGSizeMake(6*screenBounds.width/7, playHeight);
        
        rightSide = CGRectMake(568, 0, 60, 320);
        enemyTarget = [[RectTarget alloc] initWithRectLink:&rightSide andLink:&model->enemyHP andLayer:self];
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
        [self pauseModel];
        loading = true;
        
        paused_text = [[CCSprite alloc] initWithFile:@"paused_text.png"];
        [paused_text setPosition:CGPointMake([self returnScreenBounds].width/2.0f, [self returnScreenBounds].height/2.0f)];
        
        CCSprite *paused_icon = [[CCSprite alloc] initWithFile:@"pause.png"];
        [paused_icon setPosition:CGPointMake(544, 286)];
        [self addChild:paused_icon];
        
        // add label
        self->timeLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.1f", [[NSUserDefaults standardUserDefaults] floatForKey:@"playTime"]] fontName:@"Krungthep" fontSize:15.0f];
        [self->timeLabel setColor:ccc3(255, 255, 255)];
        [self->timeLabel setPosition:CGPointMake(282.0f, 307.0f)];
        [self addChild:self->timeLabel z:321];
        
        [self pauseModel];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        whiteScreen = [CCSprite node];
        
        GLubyte *buffer = (GLubyte *) malloc(sizeof(GLubyte)*4);
        
        for (int i=0;i<4;i++) {*(buffer+i)=255;}
        
        CCTexture2D *tex = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:1 pixelsHigh:1 contentSize:size];
        
        [whiteScreen setTexture:tex];
        
        [whiteScreen setTextureRect:CGRectMake(0, 0, size.width, size.height)];
        [whiteScreen setPosition:CGPointMake(size.width/2, size.height/2)];
        
        free(buffer);
        
        CCLabelTTF *levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Arena %d/5", currentLevel] fontName:@"Krungthep" fontSize:17.0f];
        [levelLabel setColor:ccc3(255, 255, 255)];
        [levelLabel setPosition:ccp(568 - 55.0f, 15.0f)];
        [self addChild:levelLabel z:321];
        
    }
    [self scheduleOnce:@selector(playStartOverlay) delay:0.5f];
    [self scheduleOnce:@selector(unpauseModel) delay:3.5f];
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
    [self pauseModel];
}

-(void) setUpResourceBars
{
    // Resource Bars
    enemyHP = [[HealthBar node] initWithOrigin:CGPointMake(screenBounds.width - BAR_PADDING, screenBounds.height - 5.0f) andOrientation:@"Left" andColor:ccc4f(0.9f, 0.3f, 0.4f, 0.7f) withLinkTo:&model->enemyHP];
    playerHP = [[HealthBar node] initWithOrigin:CGPointMake(BAR_PADDING, screenBounds.height - 5.0f) andOrientation:@"Right" andColor:ccc4f(107.0f/255.0f, 214.0f/255.0f, 119.0f/255.0f, 0.7f) withLinkTo:&model->playerHP];
    playerResources = [[RegeneratableBar node] initWithOrigin:CGPointMake(BAR_PADDING, screenBounds.height - 20.0f) andOrientation:@"Right" andColor:ccc4f(151.0f/255.0f, 176.0f/255.0f, 113.0f/255.0f, 0.7f) withLinkTo:&model->playerResources];
    [self addChild:enemyHP z:321];
    [self addChild:playerHP z:321];
    [self addChild:playerResources z:321];
    [enemyHP loadingToMaxAnimationWithTime:1.5f];
    [playerHP loadingToMaxAnimationWithTime:1.5f];
    [playerResources loadingToMaxAnimationWithTime:1.5f];
}

-(void) loadSpriteSheets
{
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    // unit sprite sheets
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"russianframes.plist"];
    CCSpriteBatchNode *russianSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"russianframes.pvr.ccz"];
    [self addChild:russianSpriteSheet];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"zombieframes.plist"];
    CCSpriteBatchNode *zombieSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"zombieframes.pvr.ccz"];
    [self addChild:zombieSpriteSheet];
    
    // meteor sprite sheets
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"meteorframes.plist"];
    CCSpriteBatchNode *meteorSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"meteorframes.pvr.ccz"];
    [self addChild:meteorSpriteSheet];
    
    CCSpriteBatchNode *overlaySpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"overlayframes.pvr.ccz"];
    [self addChild:overlaySpriteSheet];
    
    // tap indicator
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tap_indicator_frames.plist"];
    CCSpriteBatchNode *tapIndicatorSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"tap_indicator_frames.png"];
    [self addChild:tapIndicatorSpriteSheet];
}

-(void) onEnter
{
    [super onEnter];
    CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
    background.position = ccp( screenBounds.width/2, screenBounds.height/2 );
        
    [self addChild: background z:-1];
}

-(void) draw
{
    ccColor4F area_color = ccc4f(0.3f, 0.3f, 0.3f, 0.5f);
    ccDrawSolidRect(spawnArea.origin, CGPointMake(spawnArea.size.width + spawnArea.origin.x, spawnArea.size.height + spawnArea.origin.y), area_color);
    
    //area_color = ccc4f(0.4, 0.0f, 0.0f, 0.5f);
    //ccDrawSolidRect(battleArea.origin, CGPointMake(battleArea.size.width + battleArea.origin.x, battleArea.size.height + battleArea.origin.y), area_color);
}

-(void) update:(ccTime)delta
{
    if (!paused || loading)
    {
        [playerHP updateAnimation:delta];
        [enemyHP updateAnimation:delta];
        [playerResources updateAnimation:delta];
    }
    
    if (!paused)
    {
        // update the playTime!!!
        [[NSUserDefaults standardUserDefaults] setFloat:[[NSUserDefaults standardUserDefaults] floatForKey:@"playTime"]+delta forKey:@"playTime"];
        [timeLabel setString:[NSString stringWithFormat:@"%.1f", [[NSUserDefaults standardUserDefaults] floatForKey:@"playTime"]]];
    }
    
    KKInput *input = [KKInput sharedInput];
    CCArray *touches = [input touches];
    
    for (KKTouch *touch in touches)
    {
        if (!winState)
        {
            if (paused)
            {
                if ([touch phase] == KKTouchPhaseEnded || [touch phase] == KKTouchPhaseLifted || [touch phase] == KKTouchPhaseCancelled)
                {
                    [self unpause];
                    [self removeChild:paused_text];
                }
            }
            else
            {
                CGPoint pos = [touch location];
                //NSLog(@"pos: %f, %f", pos.x, pos.y);
                float size_y = 40.0f;
                float size_x = 40.0f;
                if (pos.x > 544 - size_x/2 && pos.x < 544 + size_x/2 && pos.y > 286 - size_y/2 && pos.y < 286 + size_y/2)
                {
                    [self pause];
                    for (KKTouch *touch in touches)
                    {
                        [[KKInput sharedInput] removeTouch:touch];
                    }
                    
                    [self addChild:paused_text z:231];
                    break;
                }
            }
        }
    }
}

-(void) nextFrame
{
    if (!paused)
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
    
    paused = true;
    winFlag = false;
    boss = false;
    
    NSLog(@"resetting with winState: %@", winState);
    
    if ([winState isEqualToString:@"player"])
    {
        /*
        // go back to the level select screen
        LevelSelectLayer *levelSelect = [[LevelSelectLayer alloc] initWithRegion:currentRegion];
        int currentUnlockedLevel = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"region%d_levelUnlocked", currentRegion]];
        NSLog(@"CurrentLevel: %d || LatestUnlockedLevel: %d", currentLevel, currentUnlockedLevel);
        if (currentLevel == currentUnlockedLevel)
        {
            [levelSelect unlockLevel:currentLevel + 1 ofRegion:currentRegion];
        }
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)levelSelect]];
        */
        
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[GameLayer alloc] initWithRegion:currentRegion andLevel:currentLevel+1]]];
    }
    else if ([winState isEqualToString:@"enemy"])
    {
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[GameLayer alloc] initWithRegion:currentRegion andLevel:currentLevel]]];
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
        [self playOverlay:@"win" withAdditionalDelayToCleanup:0.0f cleanup:NO];
    }
    else if ([theWinState isEqualToString:@"enemy"] || [theWinState isEqualToString:@"lose"])
    {
        [self playOverlay:@"lose" withAdditionalDelayToCleanup:0.0f cleanup:NO];
    }
    
    winState = theWinState;
    [self pauseModel];
    loading = true;
    [playerHP stopShake];
    [enemyHP stopShake];
    
    [self scheduleOnce:@selector(reset) delay:3.0f];
}

-(void) playOverlay:(NSString *)overlayType withAdditionalDelayToCleanup:(ccTime)delay cleanup:(BOOL)cleanup
{
    NSMutableArray *overlayFrames = [NSMutableArray array];
    NSString *prefix;
    NSInteger frameCount = 0;
    if ([overlayType isEqualToString:@"win"])
    {
        prefix = @"win_overlay_";
        frameCount = 16;
    }
    else if ([overlayType isEqualToString:@"lose"])
    {
        prefix = @"lose_overlay_";
        frameCount = 16;
    }
    else if ([overlayType isEqualToString:@"start"])
    {
        prefix = @"start_overlay_";
        frameCount = 14;
    }
    
    for (int i=1; i<=frameCount; i++)
    {
        [overlayFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"%@%d.png", prefix, i]]];
    }
    // play animation at 20 fps
    CCAnimation *overlayAnimation = [CCAnimation animationWithSpriteFrames:overlayFrames delay:1/20.0f];
    CCSprite *overlaySprite = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"win_overlay_1.png"]];
    
    // framecount / fps = time in seconds to finish the animation
    ccTime animationRunTime = frameCount / 20.0f;
    
    CCFiniteTimeAction *playOverlay = [CCAnimate actionWithAnimation:overlayAnimation];
    CCCallFuncND *cleanUpAction = [CCCallFuncND actionWithTarget:self selector:@selector(cleanUpSprite:) data:(__bridge void *)(overlaySprite)];
    CCSequence *playAndRemove = [CCSequence actions:playOverlay, [CCDelayTime actionWithDuration:animationRunTime + delay], cleanUpAction, nil];
    
    [overlaySprite setPosition:ccp(284, 160)];
    [self addChild:overlaySprite z:587];
    
    if (cleanup)
    {
        [overlaySprite runAction:playAndRemove];
    }
    else
    {
        [overlaySprite runAction:playOverlay];
    }
}

// needed so we can call a slightly delayed start overlay at the beginning
-(void) playStartOverlay
{
    [self playOverlay:@"start" withAdditionalDelayToCleanup:0.2f cleanup:YES];
}

-(void) cleanUpSprite:(CCSprite *)sprite
{
    [self removeChild:sprite cleanup:YES];
    [self unpauseModel];
    if (loading)
    {
        loading = false;
    }
    [myTouchHandler cleanTouches];
}

-(void) pauseModel
{
    paused = true;
    [model pauseSchedulerAndActions];
}

-(void) unpauseModel
{
    paused = false;
    [model resumeSchedulerAndActions];
}

-(void) pause
{
    paused = true;
    [model pauseSchedulerAndActions];
    [playerHP pauseSchedulerAndActions];
    [enemyHP pauseSchedulerAndActions];
    [playerResources pauseSchedulerAndActions];
    [shaker pauseSchedulerAndActions];
}

-(void) unpause
{
    paused = false;
    [model resumeSchedulerAndActions];
    [playerHP resumeSchedulerAndActions];
    [enemyHP resumeSchedulerAndActions];
    [playerResources resumeSchedulerAndActions];
    [shaker resumeSchedulerAndActions];
}

-(void)flashLongerWhiteScreen:(ccTime)time
{
    [self addChild:whiteScreen z:322];
    [self scheduleOnce:@selector(startRemovingWhiteScreen) delay:time];
}

-(void)startRemovingWhiteScreen
{
    [whiteScreen runAction:[CCFadeTo actionWithDuration:0.7f opacity:0]];
    [self scheduleOnce:@selector(cleanScreen) delay:0.7f];
}

-(void)flashWhiteScreen
{
    [self addChild:whiteScreen z:322];
    
    [whiteScreen runAction:[CCFadeTo actionWithDuration:0.7f opacity:0]];
    [self scheduleOnce:@selector(cleanScreen) delay:0.7f];
}

-(void)cleanScreen
{
    [self removeChild:whiteScreen];
    [whiteScreen setOpacity:255];
}

@end
