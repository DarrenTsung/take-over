//
//  GameLayer.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "GameLayer.h"

NSMutableArray *player_units;
CGRect touch_area;

@implementation GameLayer

-(id) init
{
    if ((self = [super init]))
    {
        NSLog(@"Game initializing...");
        
        CGSize screenBounds = [[UIScreen mainScreen] bounds].size;
        CGFloat screenWidth = screenBounds.width;
        CGFloat screenHeight = screenBounds.height;
        
        // touch_area is the player's spawning area
        touch_area.origin = CGPointMake(0.0f, 0.0f);
        touch_area.size = CGSizeMake(screenWidth/7, screenHeight);
        
        player_units = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) draw
{
    ccColor4F player_color = ccc4f(0.9f, 0.4f, 0.4f, 1.0f);
    ccColor4F area_color = ccc4f(0.8f, 0.5f, 0.5f, 0.1f);
    ccDrawSolidRect(touch_area.origin, CGPointMake(touch_area.size.width + touch_area.origin.x, touch_area.size.height + touch_area.origin.y), area_color);
}

@end
