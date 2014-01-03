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
        
        equip1 = [[CCMenuItemImage alloc] initWithNormalImage:@"backgroundEquip1.png" selectedImage:@"backgroundEquip1.png" disabledImage:@"backgroundEquip1.png" target:self selector:@selector(equipPrimary)];
        [equip1 setOpacity:OPACITY_HIGH];
        equip2 = [[CCMenuItemImage alloc] initWithNormalImage:@"backgroundEquip2.png" selectedImage:@"backgroundEquip2.png" disabledImage:@"backgroundEquip2.png" target:self selector:@selector(equipSecondary)];
        [equip2 setOpacity:OPACITY_LOW];
        CCMenu *equipMenu = [CCMenu menuWithItems:equip1, equip2, nil];
        [equipMenu alignItemsHorizontally];
        equipMenu.position = ccp(280, [equip1 boundingBox].size.height/2);
        [self addChild:equipMenu];
        
        // equipped == 0 : use primaryEquip
        // equipped == 1 : use secondaryEquip
        // start out with primaryEquip
        equipped = 0;
        
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

-(void) equipPrimary
{
    equipped = 0;
    [secondarySummon reset];
    [equip1 setOpacity:OPACITY_HIGH];
    [equip2 setOpacity:OPACITY_LOW];
}

-(void) equipSecondary
{
    equipped = 1;
    [primarySummon reset];
    [equip1 setOpacity:OPACITY_LOW];
    [equip2 setOpacity:OPACITY_HIGH];
}

-(void) update:(ccTime)delta
{
    if (!viewController->isDone)
    {
        KKInput *input = [KKInput sharedInput];
        CCArray *touches = [input touches];
        
        for (KKTouch *touch in touches)
        {
            if (equipped == 0)
            {
                [primarySummon handleTouch:touch];
            }
            else
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
