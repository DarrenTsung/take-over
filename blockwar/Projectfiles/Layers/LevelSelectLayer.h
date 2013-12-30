//
//  LevelSelectLayer.h
//  takeover
//
//  Created by Darren Tsung on 12/25/13.
//
//

#import "CCLayer.h"

@interface LevelSelectLayer : CCLayer
{
    @public
    NSMutableDictionary *levelPointers;
}
-(void) unlockNextLevel;


@end
