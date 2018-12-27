//
//  GameViewController.m
//  Breaker
//
//  Created by 김혁 on 21/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "GameViewController.h"
#import "GameHelper.h"
#import "SCNAction+Extensions.h"

#include "random_util.h"
#include "SCNVector3Util.h"

typedef enum
{
  ColliderType_Ball     = 0x01,
  ColliderType_Barrier  = 0x02,
  ColliderType_Brick    = 0x04,
  ColliderType_Paddle   = 0x08,
} ColliderType;

@implementation GameViewController {
  SCNView*    _view;
  SCNScene*   _scene;
  
  SCNNode*    _floorNode;
  SCNNode*    _horizontalCameraNode;
  SCNNode*    _verticalCameraNode;

  SCNNode*    _ballNode;
  SCNNode*    _paddleNode;
  
  SCNNode*    _lastContactNode;
  
  GameHelper*     _game;
  
  CGFloat     _touchX;
  CGFloat     _paddleX;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _lastContactNode = nil;
  
  _touchX = 0;
  _paddleX = 0;
  
  _game = [GameHelper sharedInstance];

  [self setupView];
  [self setupScene];
  [self setupCamera];
  [self setupHUD];
  [self setupSounds];

  NSClickGestureRecognizer *clickGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  NSMutableArray *gestureRecognizers = [NSMutableArray array];
  [gestureRecognizers addObject:clickGesture];
  [gestureRecognizers addObjectsFromArray:_view.gestureRecognizers];
  _view.gestureRecognizers = gestureRecognizers;
}

- (void)setupView
{
  _view = (SCNView*)self.view;
  
  _view.backgroundColor = [NSColor blackColor];
  
  _view.showsStatistics = true;
  _view.allowsCameraControl = false;
  _view.autoenablesDefaultLighting = true;
  
  _view.delegate = self;
  
  [_view setPlaying:true];
}

- (void)setupScene
{
  _scene = [SCNScene sceneNamed:@"Breaker.scnassets/Scenes//Game.scn"];
  
  _view.scene = _scene;
  
  _floorNode = [_scene.rootNode childNodeWithName:@"Floor" recursively:true];
  _ballNode = [_scene.rootNode childNodeWithName:@"Ball" recursively:true];
  _paddleNode = [_scene.rootNode childNodeWithName:@"Paddle" recursively:true];
  
  _ballNode.physicsBody.contactTestBitMask =
    ColliderType_Barrier | ColliderType_Brick | ColliderType_Paddle;
  
  _scene.physicsWorld.contactDelegate = self;
}

- (void)setupCamera
{
  _horizontalCameraNode = [_scene.rootNode childNodeWithName:@"HorizontalCamera" recursively:true];
  _verticalCameraNode = [_scene.rootNode childNodeWithName:@"VerticalCamera" recursively:true];
  
  SCNLookAtConstraint* c = [SCNLookAtConstraint lookAtConstraintWithTarget:_floorNode];
  
  [_horizontalCameraNode setConstraints:@[c]];
  [_verticalCameraNode setConstraints:@[c]];
  
  // XXX
  // using only h-camera for now
  //
  _view.pointOfView = _horizontalCameraNode;
}

- (void)setupHUD {
  _game.hudNode.position = SCNVector3Make(0.0, 0.0, -9.5);
  [_scene.rootNode addChildNode:_game.hudNode];
}

- (void)setupSounds {
  [_game loadSoundName:@"Paddle" FileNamed:@"Breaker.scnassets/Sounds/Paddle.wav"];
  [_game loadSoundName:@"Block0" FileNamed:@"Breaker.scnassets/Sounds/Block0.wav"];
  [_game loadSoundName:@"Block1" FileNamed:@"Breaker.scnassets/Sounds/Block1.wav"];
  [_game loadSoundName:@"Block2" FileNamed:@"Breaker.scnassets/Sounds/Block2.wav"];
  [_game loadSoundName:@"Barrier" FileNamed:@"Breaker.scnassets/Sounds/Barrier.wav"];
}

- (void)handleTap:(NSGestureRecognizer *)gestureRecognizer {
}

- (void)scrollWheel:(NSEvent *)theEvent
{
  float dx = [theEvent deltaX];
  SCNVector3 pos;
  
  pos = _paddleNode.position;
  pos.x += (dx * 0.2);
  
  if(pos.x > 4.5) {
    pos.x = 4.5;
  }
  
  if(pos.x < -4.5) {
    pos.x = -4.5;
  }
  
  _paddleNode.position = pos;
  
  pos = _verticalCameraNode.position;
  pos.x = _paddleNode.position.x;
  _verticalCameraNode.position = pos;
  
  pos = _horizontalCameraNode.position;
  pos.x = _paddleNode.position.x;
  _horizontalCameraNode.position = pos;
}
@end

////////////////////////////////////////////////////////////////////////////////////////
//
// render loop extension
//
////////////////////////////////////////////////////////////////////////////////////////
@implementation GameViewController (SCNSceneRendererDelegate)
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
  
  /*
  if(_game.state == Playing)
  {
    if (time > _spawnTime)
    {
      [self spawnShapes];
      _spawnTime = time + float_random(0.2, 1.5);
    }
    [self clearScene];
  }
  [_game updateHUD];
  */
  [_game updateHUD];
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
  
  if([contact.nodeA.name isEqualToString:@"Ball"]) {
    contactNode = contact.nodeB;
  } else {
    contactNode = contact.nodeA;
  }
  
  if(_lastContactNode != nil && _lastContactNode == contactNode)
  {
    return;
  }
  
  _lastContactNode = contactNode;
  
  if(contactNode.physicsBody.categoryBitMask == ColliderType_Barrier)
  {
    if([contactNode.name isEqualToString:@"Bottom"])
    {
      _game.lives -= 1;
      if(_game.lives == 0)
      {
        [_game saveState];
        [_game reset];
      }
    }
    [_game playSound:_scene.rootNode Name:@"Barrier"];
  }
  
  if(contactNode.physicsBody.categoryBitMask == ColliderType_Brick)
  {
    _game.score += 1;
    contactNode.hidden = true;
    [contactNode runAction:[SCNAction waitForDuration:120 ThenRunBlock:^void(SCNNode * _Nonnull node) {
      node.hidden = false;
    }]];
    
    [_game playSound:_scene.rootNode Name:@"Brick0"];
  }
  
  if(contactNode.physicsBody.categoryBitMask == ColliderType_Paddle)
  {
    if([contactNode.name isEqualToString:@"Left"])
    {
      SCNVector3 v = _ballNode.physicsBody.velocity;
      float xzAngVel = scnvector3_get_xz_angle(v);
      
      xzAngVel -= convert_to_radians(20);
      
      scnvector3_set_xz_angle(&v, xzAngVel);
      
      _ballNode.physicsBody.velocity = v;
    }
    
    if([contactNode.name isEqualToString:@"Right"])
    {
      SCNVector3 v = _ballNode.physicsBody.velocity;
      float xzAngVel = scnvector3_get_xz_angle(v);
      
      xzAngVel += convert_to_radians(20);
      
      scnvector3_set_xz_angle(&v, xzAngVel);
      
      _ballNode.physicsBody.velocity = v;
    }
    [_game playSound:_scene.rootNode Name:@"Paddle"];
  }
  
  SCNVector3 ballVel = _ballNode.physicsBody.velocity;
  
  scnvector3_set_length(&ballVel, 5.0);
  _ballNode.physicsBody.velocity = ballVel;
}
@end
