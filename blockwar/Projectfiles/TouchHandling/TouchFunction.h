//
//  TouchFunction.h
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//  Object that encapsulates an area on the screen and a function
//  linked to that area (handles touches)
//

#import <Foundation/Foundation.h>
#import "GameModel.h"

@interface TouchFunction : CCNode
{
    @public
    CGRect area;
    GameModel *gameModel;
    GameLayer *viewController;
    bool isActive;
    
    KKTouch *currentTouch;
}

-(id) initWithReferenceToArea:(CGRect)theArea andReferenceToViewController:(GameLayer *)theViewController andReferenceToGameModel:(GameModel *)theGameModel;
-(void) handleTouch:(KKTouch *)touch;
-(void) reset;

@end
