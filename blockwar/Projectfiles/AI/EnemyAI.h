//
//  EnemyAI.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import <Foundation/Foundation.h>
#import "GameModel.h"
#import "GameLayer.h"

@interface EnemyAI : NSObject
{
    @private
    GameModel *model;
    ccColor4F color;
    int waveSize, rowSize;
    CGFloat spawnTimer, waveTimer, probabilityWaveDelay, waveDelay;
    GameLayer *viewController;
    int waveConsecutiveCount, maxConsecutiveWaves;
}

-(id) initAIType:(NSString *)theType withReferenceToGameModel:(GameModel *)modelMaster andViewController:(GameLayer *)theViewController;
-(void) spawnWaveWithPlayHeight:(CGFloat)playHeight;
-(void) update:(ccTime)delta;
-(void) spawnBossWithPlayHeight:(CGFloat)playHeight;
-(void) reset;

@end
