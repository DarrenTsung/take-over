//
//  Factory.h
//  takeover
//
//  Created by Darren Tsung on 1/22/14.
//
//

#import "CCNode.h"
#import "Unit.h"
#import "GameModel.h"

@interface UnitFactory : CCNode
{
    @public
    CGFloat spawnTimer, waveTimer, probabilityWaveDelay, waveDelay;
    NSInteger waveSize, rowSize, waveConsecutiveCount, maxConsecutiveWaves;
    GameModel *model;
    
    @private
    Unit *copyUnit_;
    NSInteger probabilities_[20];
}

-(id)initWithUnitToCopy:(Unit *)copyUnit andFactoryProperties:(NSDictionary *)properties andGameModel:(GameModel *)theModel;

-(void) reset;

@end
