//
//  TouchHandler.h
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//

#import <Foundation/Foundation.h>
#import "GameLayer.h"
#import "TouchFunction.h"
#import "TapAndCharge.h"
#import "SummonGiantFoot.h"
#import "MeteorStrike.h"
#import "HoldDown.h"


typedef enum
{
    equippedPrimary,
    equippedSecondary
} equippedMode;

@interface TouchHandler : CCNode
{
    @public
    GameLayer *viewController;
    GameModel *gameModel;
    TouchFunction *primarySummon, *secondarySummon, *commanderPower;
    equippedMode equipped;
    
    
    
    CCMenuItemImage *equip;
}

-(id) initWithReferenceToViewController:(GameLayer *)theReference andReferenceToGameModel:(GameModel *)theGameModel;
-(void) reset;
-(void) update:(ccTime)delta;
-(void) cleanTouches;


@end
