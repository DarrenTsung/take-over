//
//  GameModel.h
//  blockwar
//
//  Created by Darren Tsung on 11/3/13.
//
//  All germs are under His dominion!! Muhahaha..
//

#import <Foundation/Foundation.h>
#import "Unit.h"
#import "GameLayer.h"
#import "EnemyAI.h"

@interface GameModel : CCNode
{
    @public
    NSMutableArray *playerUnits, *enemyUnits, *particleArray;
    GameLayer *viewController;
    EnemyAI *theEnemy;
    
    CGFloat playerHP, playerResources, enemyHP;
}

-(id) initWithReferenceToViewController:(GameLayer *)theViewController andReferenceToLevelProperties:(NSDictionary *)levelProperties;
-(void) setReferenceToEnemyAI:(EnemyAI *)theEnemyReference;
-(void) insertUnit:(Unit *)unit intoSortedArrayWithName:(NSString *)arrayName;
-(void) checkForCollisionsAndRemove;
-(void) update:(ccTime)delta;
-(void) dealDamage:(CGFloat)damage toUnitsInDistance:(CGFloat)distance ofPoint:(CGPoint)point;
//-(void) drawUnits;
-(void) reset;

@end
