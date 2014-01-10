//
//  StartMenuLayer.m
//  blockwar
//
//  Created by Darren Tsung on 12/3/13.
//
//

#import "StartMenuLayer.h"
#import "LevelSelectLayer.h"
#import "LevelSelectLayer.h"

@implementation StartMenuLayer

CCSprite *background;

-(void) setupMenus
{
    CCMenuItemImage *startBtn = [CCMenuItemImage itemWithNormalImage:@"play.png"
                                                       selectedImage: @"play.png"
                                                              target:self
                                                            selector:@selector(doTransition:)];
    
    CCMenu *myMenu = [CCMenu menuWithItems:startBtn, nil];
    [myMenu alignItemsHorizontally];
    myMenu.position = ccp(280, 100);
    [self addChild:myMenu z:1];
    
}

-(void) preloadOverlays
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"win_overlay_frames.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lose_overlay_frames.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"start_overlay_frames.plist"];
}

-(id) init
{
    if ((self = [super init]))
	{
        // enable multi-touch
        [KKInput sharedInput].multipleTouchEnabled = YES;
        
        [self preloadOverlays];
        
        for (int i=0; i<4; i++)
        {
            // make sure that the user's data is present, if not unlock the beginning level
            NSString *key = [NSString stringWithFormat:@"region%d_levelUnlocked", i];
            NSInteger levelUnlocked = [[NSUserDefaults standardUserDefaults] integerForKey:key];
            NSLog(@"User has (Region: %d, level %d) unlocked!", i, levelUnlocked);
            if (levelUnlocked == 0)
            {
                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:key];
            }
        }
        
        CGFloat playerHP = [[NSUserDefaults standardUserDefaults] floatForKey:@"playerHP"];
        CGFloat playerResources = [[NSUserDefaults standardUserDefaults] floatForKey:@"playerResources"];
        CGFloat playerRegenRate = [[NSUserDefaults standardUserDefaults] floatForKey:@"playerRegenRate"];
        if (playerHP == 0 || playerResources == 0 || playerRegenRate == 0)
        {
            NSLog(@"HP / Resources / RegenRate not found, reset all to defaults");
            [[NSUserDefaults standardUserDefaults] setFloat:20.0f forKey:@"playerHP"];
            [[NSUserDefaults standardUserDefaults] setFloat:30.0f forKey:@"playerResources"];
            [[NSUserDefaults standardUserDefaults] setFloat:5.0f forKey:@"playerRegenRate"];
        }
        
        background = [CCSprite spriteWithFile: @"menubackground.png"];
        background.position = ccp( 280, 160 );
        
        [self addChild: background z:-1];
        [self setupMenus];
    }
    return self;
}


-(void) doTransition: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[LevelSelectLayer alloc] init]]];
}



@end
