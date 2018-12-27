//
//  GameHelperMarble.h
//  MarbleMaze
//
//  Created by 김혁 on 25/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef GameHelperMarble_h
#define GameHelperMarble_h

#import "GameHelper.h"

@interface GameHelperMarble : GameHelper
+ (GameHelperMarble*)sharedInstance;

- (void)updateHUDWithString:(NSString*)str;
@end

#endif /* GameHelperMarble_h */
