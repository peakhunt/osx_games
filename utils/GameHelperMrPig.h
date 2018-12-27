//
//  GameHelperMrPig.h
//  Mr.Pig
//
//  Created by 김혁 on 27/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef GameHelperMrPig_h
#define GameHelperMrPig_h

#import "GameHelper.h"

@interface GameHelperMrPig : GameHelper
@property int coinsBanked;
@property int coinsCollected;

+ (GameHelperMrPig*)sharedInstance;

- (void)collectionCoin;
- (BOOL)bankCoins;
- (void)reset;
@end


#endif /* GameHelperMrPig_h */
