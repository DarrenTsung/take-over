//
//  EnemyAI.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import <Foundation/Foundation.h>
#import "GermFactory.h"
#import "GameLayer.h"

@interface EnemyAI : NSObject
{
    @private
    GermFactory *spawner;
    ccColor4F color;
    int waveSize, rowSize;
    CGFloat spawnTimer, waveTimer;
    GameLayer *viewController;
}

-(id) initWithReferenceToGermFactory:(GermFactory *)germMaster andWaveTimer:(CGFloat)theWaveTimer andViewController:(GameLayer *)theViewController;
-(void) spawnWaveWithPlayHeight:(CGFloat)playHeight;
-(void) update:(ccTime)delta;
-(void) reset;

@end
