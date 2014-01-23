//
//  Entity.h
//  takeover
//
//  Created by Darren Tsung on 1/7/14.
//
//

#import "CCSprite.h"
@class GameModel; // please don't make a fowarding error, I love you Xcode

@interface Entity : CCSprite
{
    @public
    GameModel *gameModel;
}

-(bool) isCollidingWith:(Entity *)otherEntity;
-(CGFloat)width;
-(CGFloat)height;

// entities get to decide what happens to other colliding entities
-(void) actOnEntity:(Entity *)otherEntity;

-(void) removeAndCleanup;

@end
