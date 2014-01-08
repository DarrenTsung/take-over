//
//  TapAndCharge.h
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//

#import "TouchFunction.h"
#import "SuperUnit.h"
#import "Zombie.h"

@interface TapAndCharge : TouchFunction
{
    @public
    CGFloat touchIndicatorRadius;
    CGPoint touchIndicatorCenter;
    ccColor4F touchIndicatorColor;
    int spawnSize;
}

@end
