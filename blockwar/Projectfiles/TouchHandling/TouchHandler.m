//
//  TouchHandler.m
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//

#import "TouchHandler.h"

@implementation TouchHandler

-(id) initWithReferenceToViewController:(GameLayer *)theReference andReferenceToGameModel:(GameModel *)theGameModel
{
    if (self = [super init])
    {
        viewController = theReference;
        gameModel = theGameModel;
        
        // equipped == 0 : use primaryEquip
        // equipped == 1 : use secondaryEquip
        // start out with primaryEquip
        equipped = 0;
        
        NSInteger primaryEquip = [[NSUserDefaults standardUserDefaults] integerForKey:@"primaryEquip"];
        NSInteger secondaryEquip = [[NSUserDefaults standardUserDefaults] integerForKey:@"secondaryEquip"];
        
        switch (primaryEquip)
        {
            case 1:
                primarySummon = [[SummonGiantFoot alloc] initWithReferenceToArea:viewController->spawnArea andReferenceToViewController:viewController andReferenceToGameModel:gameModel];
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
                secondarySummon = [[SummonGiantFoot alloc] initWithReferenceToArea:viewController->spawnArea andReferenceToViewController:viewController andReferenceToGameModel:gameModel];
                break;
            case 0:
                secondarySummon = [[TapAndCharge alloc] initWithReferenceToArea:viewController->spawnArea andReferenceToViewController:viewController andReferenceToGameModel:gameModel];
                break;
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Where's my primary equip bitch? All I got was %d.", primaryEquip];
                break;
        }
        [self scheduleUpdate];
        [viewController addChild:self];
    }
    return self;
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
