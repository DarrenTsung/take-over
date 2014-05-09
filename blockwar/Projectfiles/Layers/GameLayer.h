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
@class RectTarget;
@class GameModel;
@class TouchHandler; // please don't make a fowarding error, I love you Xcode

@interface GameLayer : CCLayerColor
{
    @public
    CGRect spawnArea, battleArea, rightSide;
    CGFloat playHeight;
    NodeShaker *shaker;
    IndicatorSprite *tapIndicatorSprite;
    
    RectTarget *enemyTarget, *playerTarget;
    HealthBar *playerHP, *enemyHP;
    
    TouchHandler *myTouchHandler;
    CCLabelTTF *timeLabel;
    CCSprite *whiteScreen;
    
    GameModel *model;
    
    bool paused, loading;
    
    @private
    CCSprite *paused_text;
}
// returns the screen bounds, flipped since we're working in landscape mode
-(CGSize) returnScreenBounds;

-(id) initWithRegion:(RegionType)world andLevel:(int)level;
-(void) endGameWithWinState:(NSString *)theWinState;

-(void)flashLongerWhiteScreen:(ccTime)time;
-(void) flashWhiteScreen;

@end
