//
//  SuperUnit.h
//  blockwar
//
//  Created by Darren Tsung on 11/2/13.
//
//

#import "Unit.h"

@interface SuperUnit : Unit
{
    @protected
    CGFloat influenceRange;
}

-(id) initWithPosition:(CGPoint)pos;

@end
