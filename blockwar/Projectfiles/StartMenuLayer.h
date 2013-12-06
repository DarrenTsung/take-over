//
//  StartMenuLayer.h
//  blockwar
//
//  Created by Rick Ling on 12/3/13.
//
//

#import "CCLayer.h"

@interface StartMenuLayer : CCLayer

-(void) setupMenus;
-(void) doTransition: (CCMenuItem  *) menuItem;

@end
