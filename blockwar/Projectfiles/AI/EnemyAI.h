//
//  EnemyAI.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import <Foundation/Foundation.h>
#import "GameLayer.h"

@class GameModel; // please don't make a fowarding error, I love you Xcode

@interface EnemyAI : NSObject
{
    @public
    GameModel *model;
    ccColor4F color;
    int waveSize, rowSize;
    CGFloat spawnTimer, waveTimer, probabilityWaveDelay, waveDelay, playHeight;
    GameLayer *viewController;
    int waveConsecutiveCount, maxConsecutiveWaves;
}

-(id) initAIType:(NSString *)theType withReferenceToGameModel:(GameModel *)modelMaster andViewController:(GameLayer *)theViewController andPlayHeight:(CGFloat)thePlayHeight;
-(void) spawnWave;
-(void) update:(ccTime)delta;
-(void) spawnBoss;
-(void) reset;

@end
