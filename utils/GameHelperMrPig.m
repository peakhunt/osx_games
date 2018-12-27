//
//  GameHelperMrPig.m
//  GameHelperMrPig
//
//  Created by 김혁 on 27/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "GameHelperMrPig.h"

static GameHelperMrPig* _shared_instance = nil;

@implementation GameHelperMrPig

+ (void)initialize {
  _shared_instance = [[GameHelperMrPig alloc] init];
}

+ (GameHelperMrPig*)sharedInstance {
  return _shared_instance;
}

- (id)init {
  self = [super init];
  
  if(self)
  {
    self.coinsCollected = 0;
    self.coinsBanked = 0;
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _lastScore = (int)[defaults integerForKey:@"lastScore"];
    _highScore = (int)[defaults integerForKey:@"highScore"];
    */
    [self initHUD];
  }
  return self;
}


- (void)initHUD {
  SKScene*    skScene;
  
  skScene = [SKScene sceneWithSize:CGSizeMake(500, 100)];
  skScene.backgroundColor = [NSColor colorWithWhite:0.0 alpha:0.0];
  
  self.labelNode = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Bold"];
  self.labelNode.fontSize = 20;
  self.labelNode.position = CGPointMake(250, 50);
  
  [skScene addChild:self.labelNode];
  
  SCNPlane* plane = [SCNPlane planeWithWidth:5 height:1];
  SCNMaterial*  material = [SCNMaterial material];
  
  material.lightingModelName = SCNLightingModelConstant;
  [material setDoubleSided:true];
  [[material diffuse] setContents:skScene];
  [plane setMaterials:@[material]];
  
  self.hudNode = [SCNNode nodeWithGeometry:plane];
  self.hudNode.name = @"HUD";
  self.hudNode.rotation = SCNVector4Make(1, 0, 0, 3.14159265);
  self.hudNode.position = SCNVector3Make(0, 2, -6.0);
}

- (void)updateHUD {
  NSString* coinsBankedFormatted = [NSString stringWithFormat:@"%0d", _coinsBanked];
  NSString* coinsCollectedFormatted = [NSString stringWithFormat:@"%0d", _coinsCollected];
  
  self.labelNode.text = [NSString stringWithFormat:@"🐽 %@ | 🏡 %@",
                     coinsCollectedFormatted,
                     coinsBankedFormatted];
}

- (void)collectionCoin {
  self.coinsCollected += 1;
}

- (BOOL)bankCoins {
  self.coinsBanked += self.coinsCollected;
  
  if(self.coinsCollected > 0) {
    self.coinsCollected = 0;
    return true;
  }
  return false;
}

- (void)reset {
  self.coinsCollected = 0;
  self.coinsBanked = 0;
}
@end
