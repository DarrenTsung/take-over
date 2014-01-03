//
//  HoldDown.h
//  takeover
//
//  Created by Darren Tsung on 1/3/14.
//
//

#import "TouchFunction.h"

@interface HoldDown : TouchFunction
{
    @public
    CGFloat touchIndicatorRadius;
    CGPoint touchIndicatorCenter;
    ccColor4F touchIndicatorColor;
    int spawnSize;
    CGFloat spawnRate;
}

@end
