//
//  EnemyAI.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import <Foundation/Foundation.h>

@interface EnemyAI : NSObject
{
    @private
    NSMutableArray *army;
    ccColor4F color;
    int wave_size;
}

-(id) initWithReferenceToEnemyArray:(NSMutableArray *)army_array;
-(void) spawnWave;

@end
