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
#import "HoldDown.h"

@interface TouchHandler : CCNode
{
    @public
    GameLayer *viewController;
    GameModel *gameModel;
    TouchFunction *primarySummon, *secondarySummon, *commanderPower;
    int equipped;
}

-(id) initWithReferenceToViewController:(GameLayer *)theReference andReferenceToGameModel:(GameModel *)theGameModel;
-(void) reset;


@end
