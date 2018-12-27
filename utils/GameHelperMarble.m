//
//  GameHelperMarble.m
//  MarbleMaze
//
//  Created by 김혁 on 25/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "GameHelperMarble.h"

static GameHelperMarble* _shared_instance = nil;

@implementation GameHelperMarble

+ (void)initialize {
  _shared_instance = [[GameHelperMarble alloc] init];
}

+ (GameHelperMarble*)sharedInstance {
  return _shared_instance;
}

- (void)initHUD {
  SKScene*    skScene;
  
  skScene = [SKScene sceneWithSize:CGSizeMake(1000, 100)];
  skScene.backgroundColor = [NSColor colorWithWhite:0.0 alpha:0.0];
  
  self.labelNode = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Bold"];
  self.labelNode.fontSize = 45;
  self.labelNode.position = CGPointMake(500, 50);
  
  [skScene addChild:self.labelNode];
  
  SCNPlane* plane = [SCNPlane planeWithWidth:3.5 height:0.2];
  SCNMaterial*  material = [SCNMaterial material];
  
  material.lightingModelName = SCNLightingModelConstant;
  [material setDoubleSided:true];
  [[material diffuse] setContents:skScene];
  [plane setMaterials:@[material]];
  
  self.hudNode = [SCNNode nodeWithGeometry:plane];
  self.hudNode.name = @"HUD";
  self.hudNode.rotation = SCNVector4Make(1, 0, 0, 3.14159265);
  self.hudNode.position = SCNVector3Make(0, 1, -3.0);
}

- (void)updateHUD {
  NSString* scoreFormatted = [NSString stringWithFormat:@"%04d", self.score];
  
  self.labelNode.text = scoreFormatted;
}

- (void)updateHUDWithString:(NSString*)str {
  self.labelNode.text = str;
}

@end
