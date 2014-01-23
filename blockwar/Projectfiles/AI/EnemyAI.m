//
//  EnemyAI.m
//  blockwar
//
//  Created by Darren Tsung on 10/31/13.
//
//

#import "EnemyAI.h"
#import "Unit.h"
#import "GameModel.h"
#import "GameLayer.h"
#import "UnitFactory.h"

#define PADDING 20.0f

#define ARC4RANDOM_MAX 0x100000000

@implementation EnemyAI

-(id) initAIType:(NSString *)theType withReferenceToGameModel:(GameModel *)theModel andViewController:(GameLayer *)theViewController andPlayHeight:(CGFloat)thePlayHeight
{
    if((self = [super init]))
    {
        NSString *AIpath = [[NSBundle mainBundle] pathForResource:theType ofType:@"plist"];
        NSArray *AIproperties = [NSArray arrayWithContentsOfFile:AIpath];
        
        model = theModel;
        viewController = theViewController;
        
        factories_ = [[NSMutableArray alloc] init];
        for (NSInteger i=0; i<(NSInteger)[AIproperties count]; i++)
        {
            NSDictionary *factoryProperties = [AIproperties objectAtIndex:i];
            NSInteger intUnitType = [[factoryProperties objectForKey:@"UnitType"] integerValue];
            UnitType *unitType;
            switch (intUnitType)
            {
                case 0:
                    unitType = VILLAGER;
                    break;
                case 1:
                    unitType = MELEE;
                    break;
                case 2:
                    unitType = SPECIAL;
                    break;
                case 3:
                    unitType = GUNMAN;
                    break;
                case 4:
                    unitType = BOSS;
                    break;
                default:
                    [NSException raise:NSInternalInconsistencyException format:@"Invalid UnitType!"];
                    break;
            }
            UnitFactory *thisFactory = [[UnitFactory alloc] initWithUnitToCopy:[self returnBasicUnit:unitType] andFactoryProperties:factoryProperties andGameModel:model];
            
            [factories_ addObject:thisFactory];
        }
    }
    return self;
}

// override this for each AI type
-(Unit *) returnBasicUnit:(UnitType)unitType
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override returnBasicUnit in a subclass"];
    return nil;
}

-(void) spawnBosswithProperties:(NSDictionary *)bossProperties
{
    Unit *bossUnit = [self returnBasicUnit:BOSS];
    CGFloat randomPos = arc4random_uniform(viewController->playHeight/3) + viewController->playHeight/3;
    Unit *theBoss = [bossUnit UnitWithPosition:CGPointMake(595, randomPos)];
    [model insertEntity:theBoss intoSortedArrayWithName:@"enemy"];
    [theBoss setInvincibleForTime:0.4f];
    NSArray *layerColors = [bossProperties objectForKey:@"layerProperties"];
    NSInteger layerCount = [layerColors count];
    [viewController->enemyHP changeLinkTo:[theBoss healthPtr] with:layerCount layersWithColors:layerColors];
    [viewController->enemyHP loadingToMaxAnimationWithTime:1.7f];
}

-(void) update:(ccTime)delta
{
    // pass along updates to children
    for (NSInteger i=0; i<(NSInteger)[factories_ count]; i++)
    {
        UnitFactory *curr = (UnitFactory *)[factories_ objectAtIndex:i];
        [curr update:delta];
    }
}

-(void) reset
{
    // reset factories
    for (NSInteger i=0; i<(NSInteger)[factories_ count]; i++)
    {
        [(UnitFactory *)[factories_ objectAtIndex:i] reset];
    }
}

@end
