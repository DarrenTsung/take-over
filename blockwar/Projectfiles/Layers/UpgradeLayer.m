//
//  UpgradeLayer.m
//  takeover
//
//  Created by Darren Tsung on 12/28/13.
//
//

#import "UpgradeLayer.h"

#define ICON_PADDING 20

@implementation UpgradeLayer


-(id) init
{
    if (self = [super init]) {
        NSString *upgradePath = [[NSBundle mainBundle] pathForResource:@"upgradeConfig" ofType:@"plist"];
        NSDictionary *upgradeProperties = [NSDictionary dictionaryWithContentsOfFile:upgradePath];
        
        backgroundImage = [CCSprite spriteWithFile:[upgradeProperties objectForKey:@"backgroundName"]];
        backgroundImage.position = ccp( 284, 160 );

        [self addChild:backgroundImage z:-1];
        [self setUpDisplayWithInformation:[upgradeProperties objectForKey:@"unitDisplays"]];
    }
    return self;
}

-(void) setUpDisplayWithInformation:(NSArray *)displayInformation
{
    CCMenu *baseMenu = [CCMenu menuWithItems: nil];
    for (int i=0; i<(int)[displayInformation count]; i++)
    {
        NSDictionary *unitDisplayInformation = [displayInformation objectAtIndex:i];
        // row of icons at the bottom
        CGPoint iconPosition = CGPointMake(20 + i*ICON_PADDING, 10);
        CCMenuItemImage *icon = [CCMenuItemImage itemWithNormalImage:[unitDisplayInformation objectForKey:@"imageName"]
                                                       selectedImage:[unitDisplayInformation objectForKey:@"selectedImageName"]
                                                               block:^(id sender){
                                                                   
                                                               }];
        [icon setPosition:iconPosition];
        [icon setAnchorPoint:ccp(0, 0)];
        [baseMenu addChild:icon];
    }
    [baseMenu setPositionRelativeToParentPosition:ccp(0, 0)];
    [backgroundImage addChild:baseMenu z:1];
}


@end
