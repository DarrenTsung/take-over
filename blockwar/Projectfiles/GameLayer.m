//
//  GameLayer.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "GameLayer.h"
#import "Germ.h"

NSMutableArray *player_units;
CGRect touch_area;

@implementation GameLayer

-(id) init
{
    if ((self = [super init]))
    {
        NSLog(@"Game initializing...");
        
        CGSize screenBounds = [[UIScreen mainScreen] bounds].size;
        // remember that we're in landscape mode
        CGFloat screenWidth = screenBounds.height;
        CGFloat screenHeight = screenBounds.width;
        NSLog(@"The screen width and height are (%f, %f)", screenWidth, screenHeight);
        
        // touch_area is the player's spawning area
        touch_area.origin = CGPointMake(0.0f, 0.0f);
        touch_area.size = CGSizeMake(screenWidth/7, screenHeight);
        
        player_units = [[NSMutableArray alloc] init];
    }
    [self schedule:@selector(nextFrame) interval:0.03]; // updates 30 frames a second (hopefully?)
    [self scheduleUpdate];
    return self;
}

-(void) draw
{
    ccColor4F player_color = ccc4f(0.9f, 0.4f, 0.4f, 1.0f);
    ccColor4F area_color = ccc4f(0.4f, 0.6f, 0.5f, 0.1f);
    ccDrawSolidRect(touch_area.origin, CGPointMake(touch_area.size.width + touch_area.origin.x, touch_area.size.height + touch_area.origin.y), area_color);
    
    for (Germ *unit in player_units)
    {
        [unit draw];
    }
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput* input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    if(input.touchesAvailable)
    {
        if (CGRectContainsPoint(touch_area, pos))
        {
            [player_units addObject:[[Germ alloc] initWithPosition:pos]];
        }
    }
}

-(void) nextFrame
{
    for (Germ *unit in player_units)
    {
        [unit update:0.03];
    }
}


@end
