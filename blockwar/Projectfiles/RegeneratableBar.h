//
//  RegeneratableBar.h
//  blockwar
//
//  Created by Darren Tsung on 11/1/13.
//
//

#import "Bar.h"

@interface RegeneratableBar : Bar
{
    @private
    CGFloat regen_rate;
}

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor;
-(void) update:(ccTime) delta;

@end
