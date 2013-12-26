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
