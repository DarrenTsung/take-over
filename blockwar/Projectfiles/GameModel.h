//
//  GermFactory.h
//  blockwar
//
//  Created by Darren Tsung on 11/3/13.
//
//  All germs are under His dominion!! Muhahaha..
//

#import <Foundation/Foundation.h>
#import "Unit.h"
#import "GameLayer.h"

@interface GameModel : NSObject
{
    @public
    NSMutableArray *playerUnits, *enemyUnits, *playerSuperUnits, *particleArray;
    GameLayer *viewController;
}

-(id) initWithReferenceToViewController:(GameLayer *)theViewController;
-(void) insertUnit:(Unit *)unit intoSortedArrayWithName:(NSString *)arrayName;
-(void) checkForCollisionsAndRemove;
-(void) update:(ccTime)delta;
//-(void) drawUnits;
-(void) reset;

-(bool) doesSuperUnitExist;

@end
