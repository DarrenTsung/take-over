//
//  EnemyAI.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import <Foundation/Foundation.h>
#import "GermFactory.h"

@interface EnemyAI : NSObject
{
    @private
    GermFactory *spawner;
    ccColor4F color;
    int waveSize, rowSize;
}

-(id) initWithReferenceToGermFactory:(GermFactory *)germMaster;
-(void) spawnWaveWithPlayHeight:(CGFloat)playHeight;

@end
