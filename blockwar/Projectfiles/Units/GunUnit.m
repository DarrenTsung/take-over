//
//  GunUnit.m
//  takeover
//
//  Created by Darren Tsung on 1/23/14.
//
//

#import "GunUnit.h"
#import "GameModel.h"

@implementation GunUnit

-(id) initWithPosition:(CGPoint)pos
{
    if ((self = [super initWithPosition:pos]))
    {
        shootingPrefix_ = @"_shoot";
        targets_ = nil;
        shooting_ = false;
        cantShoot_ = false;
        pushBack = -30.0f;
        [self setDamage:0.2];
    }
    [self schedule:@selector(scanForTargets) interval:1.0f];
    return self;
}

-(void) setUpShootingAnimationAction
{
    NSMutableArray *shootingFrames = [NSMutableArray array];
    NSMutableArray *whiteShootingFrames = [NSMutableArray array];
    for (int i=0; i<=1; i++)
    {
        [shootingFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"%@%@%d.png", name, shootingPrefix_, i]]];
        [whiteShootingFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"%@%@_white%d.png", name, shootingPrefix_, i]]];
    }
    // we want to shoot every two frames so set delay to be 1/magazineSize*2 (complete 2*magazineSize frames per second)
    CGFloat shootingFrameDelay = 1.0f / (shotsPerSecond_*2);
    CCAnimation *shootingAnimation = [CCAnimation animationWithSpriteFrames:shootingFrames delay:shootingFrameDelay];
    shootingAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:shootingAnimation] times:magazineSize_];
    
    // white sprite copies the animation underneath
    CCAnimation *whiteShootingAnimation = [CCAnimation animationWithSpriteFrames:whiteShootingFrames delay:shootingFrameDelay];
    whiteSpriteShootingAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:whiteShootingAnimation] times:magazineSize_];
}

-(void) prepareToShoot
{
    maxVelocity = 0;
    
    shooting_ = true;
    // set animation
    [self runAction:shootingAction];
    [whiteSprite runAction:whiteSpriteShootingAction];
    // shooting occurs
    CGFloat shotDelay = 1.0f / shotsPerSecond_;
    CGFloat finishShootingDelay = magazineSize_*(1.0f/shotsPerSecond_);
    [self schedule:@selector(shoot) interval:shotDelay repeat:magazineSize_-1 delay:0.0f];
    [self scheduleOnce:@selector(finishShooting) delay:finishShootingDelay + 0.3f];
}

-(void) scanForTargets
{
    if (!shooting_ && !cantShoot_) {
        // the shot range starts at half height below the bottom of the unit
        // and goes to half height above the top of the unit
        targets_ = [gameModel returnLeadingPlayer:1 UnitsInRange:shotRange];
        
        if ([targets_ count] > 0)
        {
            [self prepareToShoot];
        }
    }
}

-(void) finishInit
{
    [super finishInit];
    shotRange = NSMakeRange(origin.y - (3*[self height])/2, 3*[self height]);
}

-(void) update:(ccTime) delta
{
    [self computePosition:delta];
    
    if (!shooting_)
    {
        [self computeFrame:delta];
    }
}

-(void) shoot
{
    targets_ = [gameModel returnLeadingPlayer:1 UnitsInRange:shotRange];
    Unit *unitToShootAt;
    if ([targets_ count] > 0)
    {
        unitToShootAt = [targets_ objectAtIndex:0];
        if ((arc4random_uniform(100)/100) <= percentHit_)
        {
            [unitToShootAt hitFor:rangeDamage];
            [unitToShootAt flashWhiteFor:0.8f];
        }
    }
}

-(void) finishShooting
{
    targets_ = nil;
    shooting_ = false;
    cantShoot_ = true;
    maxVelocity = baseMaxVelocity;
    
    [self scheduleOnce:@selector(canShoot) delay:reloadTime_];
}

-(void) canShoot
{
    cantShoot_ = false;
}


@end
