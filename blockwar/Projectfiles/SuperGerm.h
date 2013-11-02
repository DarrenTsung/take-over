//
//  SuperGerm.h
//  blockwar
//
//  Created by Darren Tsung on 11/2/13.
//
//

#import "Germ.h"

@interface SuperGerm : Germ
{
    @protected
    CGFloat influenceRange;
}

-(id) initWithPosition:(CGPoint)pos;
-(void) influenceUnits:(NSMutableArray *)unitArray;

@end
