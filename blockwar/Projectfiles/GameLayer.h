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

-(CGSize) returnScreenBounds;
-(void) handleMessage:(NSArray *)message;

@end
