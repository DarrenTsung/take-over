//
//  GameLayer.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "CCLayer.h"
#import "HealthBar.h"

@interface GameLayer : CCLayerColor
{
    @public
    CGRect touchArea;
    CGFloat playHeight;
    
    HealthBar *playerHP, *enemyHP;
}
// returns the screen bounds, flipped since we're working in landscape mode
-(CGSize) returnScreenBounds;

-(id) initWithWorld:(int)world andLevel:(int)level;
-(void) endGameWithWinState:(NSString *)theWinState;

@end
