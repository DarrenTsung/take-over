//
//  RussianAI.m
//  takeover
//
//  Created by Darren Tsung on 1/21/14.
//
//

#import "GameModel.h"
#import "RussianAI.h"
#import "RussianVillager.h"
#import "RussianMelee.h"
#import "RussianBoss.h"

@implementation RussianAI

-(Unit *) returnBasicUnit:(UnitType)unitType
{
    Unit *unit = nil;
    switch (unitType) {
        case VILLAGER:
            unit = [[RussianVillager alloc] init];
            break;
            
        case MELEE:
            unit = [[RussianMelee alloc] init];
            break;
            
        case BOSS:
            unit = [[RussianBoss alloc] init];
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid UnitType!"];
            break;
    }
    return unit;
}

@end
