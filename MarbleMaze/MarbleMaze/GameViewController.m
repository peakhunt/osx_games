//
//  GameViewController.m
//  MarbleMaze
//
//  Created by 김혁 on 24/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "GameViewController.h"
#import "SCNAction+Extensions.h"
#import "GameHelper.h"
#import "GameHelperMarble.h"

#include "SCNVector3Util.h"

typedef enum
{
  Collision_Category_Ball   = 0x01,
  Collision_Category_Stone  = 0x02,
  Collision_Category_Pillar = 0x04,
  Collision_Category_Crate  = 0x08,
  Collision_Category_Pearl  = 0x10,
} Collision_Cateogry_t;

@implementation GameViewController {
  SCNView*  _view;
  SCNScene* _scene;
  
  SCNNode*  _ballNode;
  SCNNode*  _cameraNode;
  
  SCNNode*  _cameraFollowNode;
  SCNNode*  _lightFollowNode;
  
  GameHelperMarble*   _game;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
 
  _game = [GameHelperMarble sharedInstance];
  
  [self setupScene];
  [self setupNodes];
  [self setupSounds];
  
  [self resetGame];
}

- (void)setupScene {
  _view = (SCNView*)self.view;
  
  _view.delegate = self;
  // _view.allowsCameraControl = true;
  _view.showsStatistics = true;
  //_view.debugOptions = SCNDebugOptionShowWireframe;

  
  _scene = [SCNScene sceneNamed:@"art.scnassets/game.scn"];
  _view.scene = _scene;
  
  _ballNode = [_scene.rootNode childNodeWithName:@"ball" recursively:true];
  _ballNode.physicsBody.contactTestBitMask =
    Collision_Category_Pillar | Collision_Category_Crate | Collision_Category_Pearl;
  
  _scene.physicsWorld.contactDelegate = self;
  
  _cameraNode = [_scene.rootNode childNodeWithName:@"camera" recursively:true];
  SCNLookAtConstraint* c = [SCNLookAtConstraint lookAtConstraintWithTarget:_ballNode];
  c.gimbalLockEnabled = true;
  
  [_cameraNode setConstraints:@[c]];
  [_cameraNode addChildNode:_game.hudNode];
  
  _cameraFollowNode = [_scene.rootNode childNodeWithName:@"follow_camera" recursively:true];
  _lightFollowNode = [_scene.rootNode childNodeWithName:@"follow_light" recursively:true];
  
  //_view.pointOfView = _cameraNode;
  
  NSClickGestureRecognizer *clickGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  NSMutableArray *gestureRecognizers = [NSMutableArray array];
  [gestureRecognizers addObject:clickGesture];
  [gestureRecognizers addObjectsFromArray:_view.gestureRecognizers];
  _view.gestureRecognizers = gestureRecognizers;
}

- (void)setupNodes {
  
}

- (void)setupSounds {
  [_game loadSoundName:@"GameOver" FileNamed:@"art.scnassets/Sounds/GameOver.wav"];
  [_game loadSoundName:@"PowerUp" FileNamed:@"art.scnassets/Sounds/Powerup.wav"];
  [_game loadSoundName:@"Reset" FileNamed:@"art.scnassets/Sounds/Reset.wav"];
  [_game loadSoundName:@"Bump" FileNamed:@"art.scnassets/Sounds/Bump.wav"];
}

- (void)handleTap:(NSGestureRecognizer *)gestureRecognizer {
  if(_game.state == TapToPlay)
  {
    [self playGame];
  }
}

- (void)playGame {
  SCNVector3 v;
  
  _game.state = Playing;
  
  v = _cameraFollowNode.eulerAngles;
  v.y = 0;
  
  _cameraFollowNode.eulerAngles = v;
  
  _cameraFollowNode.position = SCNVector3Zero;
  
  //[self replenishLife];
}

- (void)resetGame {
  _game.state = TapToPlay;
  
  [_game playSound:_ballNode Name:@"Reset"];
  
  _ballNode.physicsBody.velocity = SCNVector3Zero;
  _ballNode.position = SCNVector3Make(0, 10, 0);
  
  _cameraFollowNode.position = _ballNode.position;
  _lightFollowNode.position = _ballNode.position;
  
  _view.playing = true;
  
  [_game reset];
}

- (void)testForGameOver {

  
  if(_ballNode.presentationNode.position.y < -5) {
    _game.state = GameOver;

    [_game playSound:_ballNode Name:@"GameOver"];
    
    [_ballNode runAction:[SCNAction waitForDuration:5 ThenRunBlock:^void (SCNNode * _Nonnull node) {
      [self resetGame];
    }]];
  }
}

- (void)scrollWheel:(NSEvent *)theEvent
{
  if(_game.state == Playing)
  {
    float dx = [theEvent deltaX];
    float dy = [theEvent deltaY];
  
    SCNVector3 motionForce = SCNVector3Make(dx * 0.005, 0, dy * -0.005);
  
    _ballNode.physicsBody.velocity = scnvector3_add(_ballNode.physicsBody.velocity, motionForce);
  }
}

- (void)updaeCameraAndLight {
  SCNVector3 camPos = _cameraFollowNode.position;
  
  float lerpX = (_ballNode.presentationNode.position.x - camPos.x) * 0.01;
  float lerpY = (_ballNode.presentationNode.position.y - camPos.y) * 0.01;
  float lerpZ = (_ballNode.presentationNode.position.z - camPos.z) * 0.01;
  
  camPos.x += lerpX;
  camPos.y += lerpY;
  camPos.z += lerpZ;
  
  _cameraFollowNode.position = camPos;
  
  _lightFollowNode.position = _cameraFollowNode.position;
  
  if(_game.state == TapToPlay) {
    SCNVector3 angle = _cameraFollowNode.eulerAngles;
    
    angle.y += 0.005;
    
    _cameraFollowNode.eulerAngles = angle;
  }
}

- (void)replenishLife {
  SCNMaterial* material = _ballNode.geometry.firstMaterial;
  
  [SCNTransaction begin];
  [SCNTransaction setAnimationDuration:1.0];
  
  material.emission.intensity = 1.0;
  
  [SCNTransaction commit];
  
  _game.score += 1;
  [_game playSound:_ballNode Name:@"PowerUp"];
}

- (void)diminishLife {
  SCNMaterial* material = _ballNode.geometry.firstMaterial;
  
  if(material.emission.intensity > 0)
  {
    material.emission.intensity -= 0.001;
  }
  else
  {
    [self resetGame];
  }
}

- (void)updateHUD {
  switch(_game.state)
  {
    case TapToPlay:
      [_game updateHUDWithString:@"-TAP TO PLAY-"];
      break;
      
    case Playing:
      [_game updateHUD];
      break;
      
    case GameOver:
      [_game updateHUDWithString:@"-GAME OVER-"];
      break;
  }
}
@end

////////////////////////////////////////////////////////////////////////////////////////
//
// render loop extension
//
////////////////////////////////////////////////////////////////////////////////////////
@implementation GameViewController (SCNSceneRendererDelegate)
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
  [self updaeCameraAndLight];
  [self updateHUD];
  
  if(_game.state == Playing)
  {
    [self testForGameOver];
    [self diminishLife];
  }
}
@end

////////////////////////////////////////////////////////////////////////////////////////
//
// collision detection extension
//
////////////////////////////////////////////////////////////////////////////////////////
@implementation GameViewController (SCNPhysicsContactDelegate)

- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact {
  SCNNode* contactNode;
  
  if([contact.nodeA.name isEqualToString:@"ball"])
  {
    contactNode = contact.nodeB;
  }
  else
  {
    contactNode = contact.nodeA;
  }
  
  if(contactNode.physicsBody.categoryBitMask == Collision_Category_Pearl)
  {
    [self replenishLife];
    contactNode.hidden = true;
    [contactNode runAction:[SCNAction waitForDuration:30 ThenRunBlock:^void(SCNNode * _Nonnull node) {
      node.hidden = false;
    }]];
  }
  
  if(contactNode.physicsBody.categoryBitMask == Collision_Category_Pillar ||
     contactNode.physicsBody.categoryBitMask == Collision_Category_Crate)
  {
    [_game playSound:_ballNode Name:@"Bump"];
  }
}
@end
