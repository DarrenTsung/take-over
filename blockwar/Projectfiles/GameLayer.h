//
//  GameLayer.h
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "CCLayer.h"

@interface GameLayer : CCLayerColor
{
    @public
    CGRect touchArea;
    CGFloat playHeight;
}
// returns the screen bounds, flipped since we're working in landscape mode
-(CGSize) returnScreenBounds;

// handles a message from outside the VC to interface with the UI
// messages come in the format [ messageType, messageArguments .. ]
-(void) handleMessage:(NSArray *)message;

-(id) initWithWorld:(int)world andLevel:(int)level;
-(void) endGameWithWinner:(NSString *)winner;

@end
