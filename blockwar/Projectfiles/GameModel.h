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
    NSDictionary *bossProperties;
    GameLayer *viewController;
    EnemyAI *theEnemy;
    CGFloat playHeight;
    CGFloat playerHP, playerResources, enemyHP;
}

-(id) initWithReferenceToViewController:(GameLayer *)theViewController andReferenceToLevelProperties:(NSDictionary *)levelProperties;
-(void) setReferenceToEnemyAI:(EnemyAI *)theEnemyReference;
-(void) insertEntity:(Entity *)entity intoSortedArrayWithName:(NSString *)arrayName;
-(void) insertUnits:(CCArray *)unitArray intoSortedArrayWithName:(NSString *)arrayName;
-(void) removeEntityFromArrays:(Entity *)entity;
-(void) checkForCollisions;
-(void) removeDeadUnitsAndCheckWinState;
-(void) update:(ccTime)delta;
-(void) dealDamage:(CGFloat)damage toUnitsInDistance:(CGFloat)distance ofPoint:(CGPoint)point;
-(void) dealDamage:(CGFloat)damage toUnitsInSprite:(CCSprite *)sprite;
-(NSMutableArray *) returnLeadingPlayer:(NSUInteger)numUnits UnitsInRange:(NSRange)range andLeftOf:(CGFloat)xPosition;
//-(void) drawUnits;
-(void) reset;

@end
