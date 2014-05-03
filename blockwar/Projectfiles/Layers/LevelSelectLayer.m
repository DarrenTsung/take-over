//
//  LevelSelectLayer.m
//  takeover
//
//  Created by Darren Tsung on 12/25/13.
//
//

#import "LevelSelectLayer.h"
#import "UpgradeLayer.h"
#import "GameLayer.h"


@implementation LevelSelectLayer

bool upgradeOnScreen;
bool isDragging;
CGPoint lastPoint;
CGPoint currentPosition;
UpgradeLayer *upgradeMenu;


-(id) init
{
    if (self = [self initWithRegion:RUSSIA])
    {
        
    }
    return self;
}

-(id) initWithRegion:(RegionType)region
{
    if ((self = [super init]))
	{
        [self setUpFrames];
        
        [self setUpMenuWithRegion:region];
        
        isDragging = false;
        upgradeOnScreen = false;
        lastPoint = CGPointZero;
        currentPosition = CGPointMake(0, 0);
        [self setPosition:currentPosition];
        levelPointers = [[NSMutableDictionary alloc] init];
        myShaker = [[NodeShaker alloc] initWithReferenceToNode:nil];
        [self addChild:myShaker];
        
        // add label
        CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Day %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"dayNumber"]] fontName:@"Krungthep" fontSize:30.0f];
        [label setColor:ccc3(95, 13, 24)];
        [label setPosition:CGPointMake(260.0f, 275.0f)];
        [self addChild:label z:321];
    }
    [self scheduleUpdate];
    return self;
}

-(void) setUpFrames
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"levelSelectFrames.plist"];
    CCSpriteBatchNode *levelSelectSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"levelSelectFrames.pvr.ccz"];
    [self addChild:levelSelectSpriteSheet];
}

-(void) setUpMenuWithRegion:(RegionType) region
{
    NSInteger levelUnlocked = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"region%d_levelUnlocked", region]];
    
    CCMenu *menu = [CCMenu menuWithItems: nil];
    NSString *prefix;
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
    }
    else if (region == AMERICA)
    {
        prefix = @"America";
    }
    NSLog(@"Prefix: %@", prefix);
    
    // set-up background
    CCSprite *background = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_background.png", prefix]]];
    background.position = ccp( 280, 160 );
    [self addChild: background z:-1];
    
    NSString *worldPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_levelselect", prefix] ofType:@"plist"];
    NSDictionary *worldProperties = [NSDictionary dictionaryWithContentsOfFile:worldPath];
    
    NSArray *levels = [worldProperties objectForKey:@"levels"];
    for (NSDictionary *level in levels)
    {
        int levelNum = [[level objectForKey:@"levelNumber"] integerValue];
        CCMenuItemImage *item;
        item = [CCMenuItemImage itemWithNormalImage:[level objectForKey:@"icon"]
                                      selectedImage:[level objectForKey:@"icon"]
                                      disabledImage:[level objectForKey:@"lockedIcon"]
                                              block:^(id sender){
                                                        NSLog(@"Level %d loaded!", levelNum);
                                                        // increment day count
                                                        [[NSUserDefaults standardUserDefaults] setInteger:([[NSUserDefaults standardUserDefaults] integerForKey:@"dayNumber"]+1) forKey:@"dayNumber"];
                                                        [self loadRegion:region withLevel:levelNum];
                                                    }];
        if (levelNum > levelUnlocked)
        {
            [item setIsEnabled:NO];
        }
        [item setPosition:CGPointMake([[level objectForKey:@"x"] floatValue], [[level objectForKey:@"y"] floatValue])];
        [menu addChild:item z:1 tag:(10*region) + levelNum];
    }
    
    [menu setPosition:ccp(0, 0)];
    [self addChild:menu z:0 tag:0];
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput *input = [KKInput sharedInput];
    CGPoint currentPoint = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    if (input.touchesAvailable)
    {
        if (input.anyTouchBeganThisFrame)
        {
            NSLog(@"current touch: %f, %f", currentPoint.x, currentPoint.y);
            // touch bottom right corner to reset the unlocked progress and reload the level select layer
            if (currentPoint.x > 500 && currentPoint.y < 40)
            {
                for (int i=0; i<4; i++)
                {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:[NSString stringWithFormat:@"region%d_levelUnlocked", i]];
                }
                [[CCDirector sharedDirector] replaceScene:
                 [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[LevelSelectLayer alloc] init]]];
            }
            // touch top right corner to open up upgrade menu
            else if (currentPoint.x < 60 && currentPoint.y < 60)
            {
                [[CCDirector sharedDirector] pushScene:
                 [CCTransitionMoveInT transitionWithDuration:0.5f scene:(CCScene*)[[UpgradeLayer alloc] init]]];
            }
            else
            {
                isDragging = true;
                lastPoint = currentPoint;
            }
        }
        else if (input.anyTouchEndedThisFrame && isDragging)
        {
            isDragging = false;
        }
        else if (input.touchesAvailable && isDragging)
        {
            // we don't care about y changes only x changes
            currentPosition.x += (currentPoint.x - lastPoint.x);
            [self setPosition:currentPosition];
            lastPoint = currentPoint;
        }
        else
        {
            // AFTER SEEING TIFFANY, ADD FRICTION ELEMENTS HERE (WHEN NO TOUCH IS OCCURING, PULL MENU BACK TO NEAREST PAGE)
        }
    }
}

-(void)unlockLevel:(int)levelNum ofRegion:(RegionType)region
{
    NSLog(@"unlock Level called!");
    // don't unlock any levels beyond 5
    if (levelNum > 5) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"region%d_levelUnlocked", region];
    int unlockedLevelTag = (10 * region) + [[NSUserDefaults standardUserDefaults] integerForKey:key] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:key] + 1 forKey:key];
    
    // [self switchToRegion:region];
    
    // grab the reference the menuItem
    unlockItem = [[self getChildByTag:0] getChildByTag:unlockedLevelTag];
    // create a unlocked image sprite over it with 0 opacity
    unlockSelectedSprite = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"level%d.png", levelNum]];
    [self scheduleOnce:@selector(unlockNextLevel) delay:0.5f];
}

-(void)unlockNextLevel
{
    [unlockSelectedSprite setPosition:unlockItem.position];
    [unlockSelectedSprite setOpacity:0];
    
    [self addChild:unlockSelectedSprite];
    // and fade it out over 1.2 seconds
    [unlockSelectedSprite runAction:[CCFadeTo actionWithDuration:1.2f opacity:255]];
    // also shake it
    [myShaker changeReferenceToNode:unlockSelectedSprite andOtherNode:unlockItem];
    [myShaker shakeWithShakeValue:5 forTime:1.2f];
    
    // set the item to enabled when animation is finished
    [self scheduleOnce:@selector(enableNextLevel) delay:1.2f];
}

-(void)enableNextLevel
{
    CCMenuItemImage *item = (CCMenuItemImage *)unlockItem;
    [unlockSelectedSprite setPosition:unlockItem.position];
    [unlockSelectedSprite setOpacity:0];
    [self removeChild:unlockSelectedSprite];
    [item setIsEnabled:YES];
}

-(void) loadRegion:(RegionType)region withLevel:(int) level
{
    [[CCDirector sharedDirector] replaceScene:(CCScene *)[[GameLayer alloc] initWithRegion:region andLevel:level]];
}

@end
