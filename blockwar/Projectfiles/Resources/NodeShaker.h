//
//  NodeShaker.h
//  takeover
//
//  Created by Darren Tsung on 1/2/14.
//
//

#import "CCNode.h"

@interface NodeShaker : CCNode
{
    @public
    CCNode *reference, *otherReference;
    CGPoint origin;
    unsigned int shakeValue;
    
    bool isShaking;
}

-(id) initWithReferenceToNode:(CCNode *)theReference;
-(void) changeReferenceToNode:(CCNode *)theReference;
-(void) shakeWithShakeValue:(unsigned int)theShakeValue forTime:(ccTime)time;
-(void) changeReferenceToNode:(CCNode *)theReference andOtherNode:(CCNode *)theOtherReference;

@end
