//
//  GunUnit.h
//  takeover
//
//  Created by Darren Tsung on 1/23/14.
//
//

#import "Unit.h"

@interface GunUnit : Unit
{
    @public
    CGFloat rangeDamage;
    
    @protected
    NSRange shotRange;
    CCAction *shootingAction, *whiteSpriteShootingAction;
    NSMutableArray *targets_;
    NSString *shootingPrefix_;
    NSUInteger magazineSize_, shotsPerSecond_;
    CGFloat percentHit_, reloadTime_;
    bool shooting_, cantShoot_;
}

-(void) setUpShootingAnimationAction;
-(void) shoot;

@end
