//
//  LevelSelectLayer.h
//  takeover
//
//  Created by Darren Tsung on 12/25/13.
//
//

#import "CCLayer.h"
#import "NodeShaker.h"

typedef enum
{
    RUSSIA,
    ASIA,
    AFRICA,
    AMERICA
} RegionType;

@interface LevelSelectLayer : CCLayer
{
    @public
    NSMutableDictionary *levelPointers;
    
    CCNode *unlockItem;
    CCSprite *unlockSelectedSprite;
    
    NodeShaker *myShaker;
}
-(void)unlockLevel:(int)levelNum ofRegion:(RegionType)region;
-(id) initWithRegion:(RegionType)region;


@end
