//
//  LevelSelectLayer.m
//  takeover
//
//  Created by Darren Tsung on 12/25/13.
//
//

#import "LevelSelectLayer.h"
#import "GameLayer.h"

@implementation LevelSelectLayer

bool isDragging;
CGPoint lastPoint;
CGPoint currentPosition;

-(id) init
{
    if ((self = [super init]))
	{
        NSInteger worldUnlocked = [[NSUserDefaults standardUserDefaults] integerForKey:@"worldUnlocked"];
        [self setUpMenuWithWorld:worldUnlocked];
        
        isDragging = false;
        lastPoint = CGPointZero;
        currentPosition = CGPointMake(0, 0);
        [self setPosition:currentPosition];
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
            item.isEnabled = false;
        }
        [item setPosition:CGPointMake([[level objectForKey:@"x"] floatValue], [[level objectForKey:@"y"] floatValue])];
        [menu addChild:item];
    }
    [menu setPosition:ccp(0, 0)];
    [self addChild:menu];
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput *input = [KKInput sharedInput];
    CGPoint currentPoint = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
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
        else
        {
            isDragging = true;
            lastPoint = currentPoint;
        }
    }
    else if (input.anyTouchEndedThisFrame)
    {
        isDragging = false;
    }
    else if (input.touchesAvailable)
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

-(void) loadWorld:(int) world withLevel:(int) level
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[GameLayer alloc] initWithWorld:world andLevel:level]]];
}

@end
