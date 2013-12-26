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

-(id) init
{
    if ((self = [super init]))
	{
        CCMenu *menu = [CCMenu menuWithItems: nil];
        int levelCount = 5;
        for (int i=1; i<=levelCount; i++)
        {
            CCMenuItemFont *item = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d", i] block:^(id sender){ [self loadWorld:1 withLevel:i]; }];
            [item setFontName:@"Palatino"];
            [menu addChild:item];
        }
        [menu alignItemsHorizontallyWithPadding:40.0f];
        menu.position = ccp(280, 100);
        [self addChild:menu];
    }
    return self;
}

-(void) loadWorld:(int) world withLevel:(int) level
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[GameLayer alloc] initWithWorld:world andLevel:level]]];
}

@end
