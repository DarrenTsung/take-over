//
//  LevelSelectLayer.m
//  takeover
//
//  Created by Darren Tsung on 12/25/13.
//
//

#import "LevelSelectLayer.h"
#import "GameLayer.h"
#import "UpgradeLayer.h"

@implementation LevelSelectLayer

bool upgradeOnScreen;
bool isDragging;
CGPoint lastPoint;
CGPoint currentPosition;
UpgradeLayer *upgradeMenu;


-(id) init
{
    if ((self = [super init]))
	{
        NSInteger worldUnlocked = [[NSUserDefaults standardUserDefaults] integerForKey:@"worldUnlocked"];
        [self setUpMenuWithWorld:worldUnlocked];
        
        isDragging = false;
        upgradeOnScreen = false;
        lastPoint = CGPointZero;
        currentPosition = CGPointMake(0, 0);
        [self setPosition:currentPosition];
        levelPointers = [[NSMutableDictionary alloc] init];
    }
    [self scheduleUpdate];
    return self;
}

-(void) setUpMenuWithWorld:(int) world
{
    NSInteger levelUnlocked = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelUnlocked"];
    
    CCMenu *menu = [CCMenu menuWithItems: nil];
    NSString *worldPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"world%d_levelselect", world] ofType:@"plist"];
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
                                                        [self loadWorld:world withLevel:levelNum];
                                                    }];
        if (levelNum > levelUnlocked)
        {
            [item setIsEnabled:NO];
        }
        [item setPosition:CGPointMake([[level objectForKey:@"x"] floatValue], [[level objectForKey:@"y"] floatValue])];
        [menu addChild:item z:1 tag:levelNum];
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
            // touch bottom right corner to reset the unlocked progress and reload the level select layer
            if (currentPoint.x > 280 && currentPoint.y < 40)
            {
                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"worldUnlocked"];
                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"levelUnlocked"];
                [[CCDirector sharedDirector] replaceScene:
                 [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[LevelSelectLayer alloc] init]]];
            }
            // touch top right corner to open up upgrade menu
            else if (currentPoint.x < 40 && currentPoint.y < 40)
            {
                [[CCDirector sharedDirector] pushScene:
                 [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[UpgradeLayer alloc] init]]];
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

-(void)unlockNextLevel
{
    NSLog(@"unlock next level called!");
    int levelNum = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelUnlocked"] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"levelUnlocked"] + 1 forKey:@"levelUnlocked"];
    
    // grab the reference the menuItem
    CCNode *item = [[self getChildByTag:0] getChildByTag:levelNum];
    // create a unlocked image sprite over it with 0 opacity
    CCSprite *selectedSprite = [[CCSprite alloc] initWithFile:[NSString stringWithFormat:@"level%d.png", levelNum]];
    [selectedSprite setPosition:item.position];
    [selectedSprite setOpacity:0];
    
    [self addChild:selectedSprite];
    // and fade it out over 2 seconds
    [selectedSprite runAction:[CCFadeTo actionWithDuration:1.2f opacity:255]];
    
    // set the item to enabled when animation is finished
    [self scheduleOnce:@selector(enableNextLevel) delay:1.2f];
}

-(void)enableNextLevel
{
    NSLog(@"just enabled the next level!");
    int levelNum = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelUnlocked"];
    
    // grab the reference the menuItem
    CCMenu *menu = (CCMenu *)[self getChildByTag:0];
    CCMenuItemImage *item = (CCMenuItemImage *)[menu getChildByTag:levelNum];
    [item setIsEnabled:YES];
}

-(void) loadWorld:(int) world withLevel:(int) level
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[GameLayer alloc] initWithWorld:world andLevel:level]]];
}

@end
