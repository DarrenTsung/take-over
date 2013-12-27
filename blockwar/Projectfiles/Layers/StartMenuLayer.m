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
        
        background = [CCSprite spriteWithFile: @"menubackground.png"];
        background.position = ccp( 280, 160 );
        
        [self addChild: background z:-1];
        [self setupMenus];
        [[CCDirector sharedDirector] setDisplayStats:NO];
    }
    return self;
}


-(void) doTransition: (CCMenuItem  *) menuItem
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[LevelSelectLayer alloc] init]]];
}



@end
