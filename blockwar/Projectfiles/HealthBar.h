//
//  HealthBar.h
//  blockwar
//
//  Created by Darren Tsung on 11/1/13.
//
//

#import <Foundation/Foundation.h>

@interface HealthBar : NSObject
{
    @private
    CGFloat current_health, max_health, modifier;
    CGSize size;
    CGPoint origin;
    NSString *orientation;
    ccColor4F color;
}

-(id) initWithOrigin:(CGPoint)theOrigin andOrientation:(NSString *)theOrientation andColor:(ccColor4F)theColor;
-(void) draw;
-(void) decreaseHealthBy:(CGFloat)value;
-(CGFloat) getCurrentValue;

@end
