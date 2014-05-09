//
//  WinLayer.m
//  blockwar
//
//  Created by Darren Tsung on 12/6/13.
//
//

#import "WinLayer.h"
#import "StartMenuLayer.h"

@implementation WinLayer

-(id) init
{
    if ((self = [super init]))
	{
        CCSprite *background = [CCSprite spriteWithFile: @"winscreen.png"];
        background.position = ccp( 280, 160 );
        
        [self addChild: background z:-1];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"You finished the run\n in %.1f seconds!", [[NSUserDefaults standardUserDefaults] floatForKey:@"playTime"]] fontName:@"Krungthep" fontSize:24.0f];
        [label setColor:ccc3(205, 205, 205)];
        [label setPosition:CGPointMake(280.0f, 100.0f)];
        
        [self addChild:label z:321];
        
        [self scheduleOnce:@selector(goToStart) delay:5.0f];
        [self scheduleUpdate];
    }
    return self;
}

-(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor
{
    CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2  height:label.texture.contentSize.height+size*2];
    CGPoint originalPos = [label position];
    ccColor3B originalColor = [label color];
    BOOL originalVisibility = [label visible];
    [label setColor:cor];
    [label setVisible:YES];
    ccBlendFunc originalBlend = [label blendFunc];
    [label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
    CGPoint bottomLeft = ccp(label.texture.contentSize.width * label.anchorPoint.x + size, label.texture.contentSize.height * label.anchorPoint.y + size);
    //CGPoint positionOffset = ccp(label.texture.contentSize.width * label.anchorPoint.x - label.texture.contentSize.width/2,label.texture.contentSize.height * label.anchorPoint.y - label.texture.contentSize.height/2);
    //use this for adding stoke to its self...
    CGPoint positionOffset= ccp(-label.contentSize.width/2,-label.contentSize.height/2);
    
    CGPoint position = ccpSub(originalPos, positionOffset);
    
    [rt begin];
    for (int i=0; i<360; i+=60) // you should optimize that for your needs
    {
        [label setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*size, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
        [label visit];
    }
    [rt end];
    [[[rt sprite] texture] setAntiAliasTexParameters];//THIS
    [label setPosition:originalPos];
    [label setColor:originalColor];
    [label setBlendFunc:originalBlend];
    [label setVisible:originalVisibility];
    [rt setPosition:position];
    return rt;
}

-(void) goToStart
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:(CCScene*)[[StartMenuLayer alloc] init]]];
}

-(void) update:(ccTime)delta
{
    // handle touch input
    KKInput *input = [KKInput sharedInput];
    CGPoint currentPoint = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    if (input.touchesAvailable)
    {
        [self goToStart];
    }
}


@end
