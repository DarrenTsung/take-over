//
//  LevelSelectLayer.m
//  takeover
//
//  Created by Darren Tsung on 12/25/13.
//
//

#import "LevelSelectLayer.h"
#import "GameLayer.h"

@implementation LevelSelectLayer

bool isDragging;
CGPoint lastPoint;
CGPoint currentPosition;

-(id) init
{
    if ((self = [super init]))
	{
        [self setUpMenuWithWorld:1];
        
        CGSize screenBounds = [[UIScreen mainScreen] bounds].size;
        // flip the height and width since we're in landscape mode
        CGFloat temp = screenBounds.height;
        screenBounds.height = screenBounds.width;
        screenBounds.width = temp;
        
        isDragging = false;
        lastPoint = CGPointZero;
        currentPosition = CGPointMake(0, 0);
        [self setPosition:currentPosition];
    }
    [self scheduleUpdate];
    return self;
}

-(void) setUpMenuWithWorld:(int) world
{
    CCMenu *menu = [CCMenu menuWithItems: nil];
    NSString *worldPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"world%d_levelselect", world] ofType:@"plist"];
    NSDictionary *worldProperties = [NSDictionary dictionaryWithContentsOfFile:worldPath];
    
    NSArray *levels = [worldProperties objectForKey:@"levels"];
    for (NSDictionary *level in levels)
    {
        int levelNum = [[level objectForKey:@"levelNumber"] integerValue];
        CCMenuItemImage *item = [CCMenuItemImage itemWithNormalImage:[level objectForKey:@"icon"]
                                                       selectedImage:[level objectForKey:@"icon"]
                                                               block:^(id sender){
                                                                   NSLog(@"Level %d loaded!", levelNum);
                                                                   [self loadWorld:world withLevel:levelNum];
                                                               }];
        [item setPosition:CGPointMake([[level objectForKey:@"x"] floatValue], [[level objectForKey:@"y"] floatValue])];
        [menu addChild:item];
    }
    [menu setPosition:ccp(0, 0)];
    [self addChild:menu];
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput *input = [KKInput sharedInput];
    CGPoint currentPoint = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    if (input.anyTouchBeganThisFrame)
    {
        isDragging = true;
        lastPoint = currentPoint;
    }
    else if (input.anyTouchEndedThisFrame)
    {
        isDragging = false;
    }
    else if (input.touchesAvailable)
    {
        // we don't care about y changes only x changes
        currentPosition.x += (currentPoint.x - lastPoint.x);
        [self setPosition:currentPosition];
        lastPoint = currentPoint;
    }
    else
    {
        // AFTER SEEING TIFFANY, ADD FRICTION ELEMENTS HERE (WHEN NO TOUCH IS OCCURING, PULL MENU BACK TO NEAREST PAGE)
        
    }
}

-(void) loadWorld:(int) world withLevel:(int) level
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[GameLayer alloc] initWithWorld:world andLevel:level]]];
}

@end
