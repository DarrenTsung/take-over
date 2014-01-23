//
//  EnemyAI.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import <Foundation/Foundation.h>
#import "GameLayer.h"
#import "Unit.h"

@class GameModel; // please don't make a fowarding error, I love you Xcode

typedef enum
{
    VILLAGER,
    MELEE,
    SPECIAL,
    GUNMAN,
    BOSS
} UnitType;

@interface EnemyAI : CCNode
{
    @public
    GameModel *model;
    GameLayer *viewController;
    
    @private
    NSMutableArray *factories_;
    
}

-(id) initAIType:(NSString *)theType withReferenceToGameModel:(GameModel *)modelMaster andViewController:(GameLayer *)theViewController andPlayHeight:(CGFloat)thePlayHeight;
-(Unit *) returnBasicUnit:(UnitType)unitType;
-(void) update:(ccTime)delta;
-(void) spawnBosswithProperties:(NSDictionary *)bossProperties;
-(void) reset;

@end
