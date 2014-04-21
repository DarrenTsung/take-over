//
//  GameLayer.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "CCLayer.h"
#import "HealthBar.h"
#import "NodeShaker.h"
#import "IndicatorSprite.h"
#import "LevelSelectLayer.h"
@class TouchHandler; // please don't make a fowarding error, I love you Xcode

@interface GameLayer : CCLayerColor
{
    @public
    CGRect spawnArea, battleArea, rightSide;
    CGFloat playHeight;
    NodeShaker *shaker;
    IndicatorSprite *tapIndicatorSprite;
    
    HealthBar *playerHP, *enemyHP;
    
    TouchHandler *myTouchHandler;
    
    bool paused;
    
    @private
    CCSprite *paused_text;
}
// returns the screen bounds, flipped since we're working in landscape mode
-(CGSize) returnScreenBounds;

-(id) initWithRegion:(RegionType)world andLevel:(int)level;
-(void) endGameWithWinState:(NSString *)theWinState;

@end
