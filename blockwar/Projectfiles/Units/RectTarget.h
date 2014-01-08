//
//  RectEntityTarget.h
//  takeover
//
//  Created by Darren Tsung on 1/7/14.
//
//

#import "Entity.h"
#import "Unit.h"

@interface RectTarget : Entity
{
    @public
    CGRect *target;
    CGFloat *targetHealth;
}
-(id) initWithRectLink:(CGRect *)rect andLink:(CGFloat *)theLink;

@end
