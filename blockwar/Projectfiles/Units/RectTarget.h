//
//  RectEntityTarget.h
//  takeover
//
//  Created by Darren Tsung on 1/7/14.
//
//

#import "Entity.h"
#import "Unit.h"
#import "BossUnit.h"
#import "GameLayer.h"

@interface RectTarget : Entity
{
    @public
    CGRect *target;
    CGFloat *targetHealth;
    GameLayer *controller;
    
}
-(id) initWithRectLink:(CGRect *)rect andLink:(CGFloat *)theLink andLayer:(GameLayer *)theController;

@end
