//
//  GermFactory.h
//  blockwar
//
//  Created by Darren Tsung on 11/3/13.
//
//  All germs are under His dominion!! Muhahaha..
//

#import <Foundation/Foundation.h>
#import "Germ.h"
#import "GameLayer.h"
#import "CircleExplosion.h"

@interface GermFactory : NSObject
{
    @public
    NSMutableArray *playerUnits, *enemyUnits, *playerSuperUnits, *particleArray;
    GameLayer *viewController;
}

-(id) initWithReferenceToViewController:(GameLayer *)theViewController;
-(void) insertGerm:(Germ *)unit intoSortedArrayWithName:(NSString *)arrayName;
-(void) checkForCollisionsAndRemove;
-(void) update:(ccTime)delta;
-(void) drawGerms;
-(void) reset;

@end
