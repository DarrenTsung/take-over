//
//  StartMenuLayer.m
//  blockwar
//
//  Created by Darren Tsung on 12/3/13.
//
//

#import "StartMenuLayer.h"
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

-(id) init
{
    if ((self = [super init]))
	{
        // make sure that the user's data is present, if not unlock the beginning level
        NSInteger worldUnlocked = [[NSUserDefaults standardUserDefaults] integerForKey:@"worldUnlocked"];
        NSInteger levelUnlocked = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelUnlocked"];
        NSLog(@"User has (world: %d, level %d) unlocked!", worldUnlocked, levelUnlocked);
        if (worldUnlocked == 0 || levelUnlocked == 0)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"worldUnlocked"];
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"levelUnlocked"];
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
