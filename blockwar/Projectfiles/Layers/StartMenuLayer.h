//
//  StartMenuLayer.h
//  blockwar
//
//  Created by Darren Tsung on 12/3/13.
//
//

#import "CCLayer.h"
#import "WinLayer.h"

@interface StartMenuLayer : CCLayer

-(void) setupMenus;
-(void) doTransition: (CCMenuItem  *) menuItem;

@end
