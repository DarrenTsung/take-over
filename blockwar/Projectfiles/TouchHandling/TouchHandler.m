//
//  TouchHandler.m
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//

#import "TouchHandler.h"

// 255 * 0.4
#define OPACITY_LOW 102
// 255 * 0.7
#define OPACITY_HIGH 178.5

@implementation TouchHandler

-(id) initWithReferenceToViewController:(GameLayer *)theReference andReferenceToGameModel:(GameModel *)theGameModel
{
    if (self = [super init])
    {
        viewController = theReference;
        gameModel = theGameModel;
        
        equip = [[CCMenuItemImage alloc] initWithNormalImage:@"equipToggleP.png" selectedImage:@"equipToggleP.png" disabledImage:@"equipToggleS.png" target:self selector:@selector(equipToggle)];
        [equip setOpacity:OPACITY_LOW];
        CCMenu *equipMenu = [CCMenu menuWithItems:equip, nil];
        [equipMenu alignItemsHorizontally];
        // put menu at bottom right corner
        equipMenu.position = ccp(568 - [equip boundingBox].size.width/2 - 15.0f, [equip boundingBox].size.height/2 + 15.0f);
        [self addChild:equipMenu z:321];
        
        // start out with primaryEquip
        equipped = equippedPrimary;
        
        NSInteger primaryEquip = [[NSUserDefaults standardUserDefaults] integerForKey:@"primaryEquip"];
        NSInteger secondaryEquip = [[NSUserDefaults standardUserDefaults] integerForKey:@"secondaryEquip"];
        
        // DEBUG
        secondaryEquip = 1;
        
        switch (primaryEquip)
        {
            case 1:
                primarySummon = [[HoldDown alloc] initWithReferenceToArea:viewController->spawnArea andReferenceToViewController:viewController andReferenceToGameModel:gameModel];
                break;
            case 0:
                primarySummon = [[TapAndCharge alloc] initWithReferenceToArea:viewController->spawnArea andReferenceToViewController:viewController andReferenceToGameModel:gameModel];
                break;
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Where's my primary equip bitch? All I got was %d.", primaryEquip];
                break;
        }
        
        switch (secondaryEquip)
        {
            case 1:
                secondarySummon = [[HoldDown alloc] initWithReferenceToArea:viewController->spawnArea andReferenceToViewController:viewController andReferenceToGameModel:gameModel];
                break;
            case 0:
                secondarySummon = [[TapAndCharge alloc] initWithReferenceToArea:viewController->spawnArea andReferenceToViewController:viewController andReferenceToGameModel:gameModel];
                break;
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Where's my primary equip bitch? All I got was %d.", primaryEquip];
                break;
        }
    }
    [self scheduleUpdate];
    [viewController addChild:self];
    return self;
}

-(void) equipToggle
{
    if (equipped == equippedPrimary)
    {
        equipped = equippedSecondary;
        [equip setNormalImage:[CCSprite spriteWithFile:@"equipToggleS.png"]];
        
        // if primary was handling a touch
        if (primarySummon->currentTouch != nil)
        {
            // reset the touch primarySummon was handling
            [primarySummon->currentTouch setTouchPhase:KKTouchPhaseBegan];
            // pass to secondarySummon the touch primarySummon was handling
            [secondarySummon handleTouch:primarySummon->currentTouch];
        }
        
        // remove and stop whatever primarySummon was doing
        [primarySummon reset];
    }
    else if (equipped == equippedSecondary)
    {
        equipped = equippedPrimary;
        [equip setNormalImage:[CCSprite spriteWithFile:@"equipToggleP.png"]];
        
        // if secondary was handling a touch
        if (secondarySummon->currentTouch != nil)
        {
            // reset the touch secondaryTouch was handling
            [secondarySummon->currentTouch setTouchPhase:KKTouchPhaseBegan];
            // pass to primarySummon the touch secondarySummon was handling
            [primarySummon handleTouch:secondarySummon->currentTouch];
        }
        
        // remove and stop whatever secondarySummon was doing
        [secondarySummon reset];
    }
    else
    {
        NSLog(@"ERROR: Equipped is some unknown number.");
    }
    [equip setOpacity:OPACITY_LOW];
}

-(void) update:(ccTime)delta
{
    if (!viewController->isDone)
    {
        KKInput *input = [KKInput sharedInput];
        CCArray *touches = [input touches];
        
        for (KKTouch *touch in touches)
        {
            if (equipped == equippedPrimary)
            {
                [primarySummon handleTouch:touch];
            }
            else if (equipped == equippedSecondary)
            {
                [secondarySummon handleTouch:touch];
            }
        }
    }
}


-(void) reset
{
    [primarySummon reset];
    [secondarySummon reset];
    [commanderPower reset];
}


@end
