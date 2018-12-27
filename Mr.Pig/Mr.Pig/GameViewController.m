//
//  ViewController.m
//  Mr.Pig
//
//  Created by 김혁 on 26/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "GameViewController.h"
#import "SCNAction+Extensions.h"
#import "GameHelperMrPig.h"

#include "random_util.h"

typedef enum
{
  BitMaskPig = 1,
  BitMaskVehicle = 2,
  BitMaskObstacle = 4,
  BitMaskFront = 8,
  BitMaskBack = 16,
  BitMaskLeft = 32,
  BitMaskRight = 64,
  BitMaskCoin = 128,
  BitMaskHouse = 256
} CollisionMask_t;

@implementation GameViewController {
  SCNView*    _view;
  
  SCNScene*   _gameScene;
  SCNScene*   _splashScene;
  
  SCNNode*    _pigNode;
  SCNNode*    _cameraNode;
  SCNNode*    _cameraFollowNode;
  SCNNode*    _lightFollowNode;
  SCNNode*    _trafficNode;
  
  SCNNode*    _collisionNode;
  SCNNode*    _frontCollisionNode;
  SCNNode*    _backCollisionNode;
  SCNNode*    _leftCollisionNode;
  SCNNode*    _rightCollisionNode;
  
  SCNAction*  _driveLeftAction;
  SCNAction*  _driveRightAction;
  
  SCNAction*  _jumpLeftAction;
  SCNAction*  _jumpRightAction;
  SCNAction*  _jumpForwardAction;
  SCNAction*  _jumpBackwardAction;
  
  SCNAction*  _triggerGameOver;
  
  int _activeCollisionsBitMask;
  
  GameHelperMrPig* _game;
  
  SCNAudioSource* _music;
  SCNAudioPlayer* _musicPlayer;
  
  SCNAudioSource* _traffic;
  SCNAudioPlayer* _trafficPlayer;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _game = [GameHelperMrPig sharedInstance];

  
  // Do any additional setup after loading the view.
  [self setupScenes];
  [self setupNodes];
  [self setupActions];
  [self setupTraffic];
  [self setupGesture];
  [self loadSounds];
  
  NSClickGestureRecognizer *clickGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  NSMutableArray *gestureRecognizers = [NSMutableArray array];
  [gestureRecognizers addObject:clickGesture];
  [gestureRecognizers addObjectsFromArray:_view.gestureRecognizers];
  _view.gestureRecognizers = gestureRecognizers;
}

- (void)setupScenes {
  _view = (SCNView*)self.view;
  _view.showsStatistics = true;
  
  _gameScene = [SCNScene sceneNamed:@"/MrPig.scnassets/GameScene.scn"];
  _splashScene = [SCNScene sceneNamed:@"/MrPig.scnassets/SplashScene.scn"];
  
  _view.scene = _splashScene;
  
  _view.delegate = self;
  
  _gameScene.physicsWorld.contactDelegate = self;
}

- (void)setupNodes {
  _pigNode = [_gameScene.rootNode childNodeWithName:@"MrPig" recursively:true];
  _cameraNode = [_gameScene.rootNode childNodeWithName:@"camera" recursively:true];
  
  [_cameraNode addChildNode:_game.hudNode];
  
  _cameraFollowNode = [_gameScene.rootNode childNodeWithName:@"FollowCamera" recursively:true];
  _lightFollowNode = [_gameScene.rootNode childNodeWithName:@"FollowLight" recursively:true];
  _trafficNode = [_gameScene.rootNode childNodeWithName:@"Traffic" recursively:true];
  
  _collisionNode = [_gameScene.rootNode childNodeWithName:@"Collision" recursively:true];
  _frontCollisionNode = [_gameScene.rootNode childNodeWithName:@"Front" recursively:true];
  _backCollisionNode = [_gameScene.rootNode childNodeWithName:@"Back" recursively:true];
  _leftCollisionNode = [_gameScene.rootNode childNodeWithName:@"Left" recursively:true];
  _rightCollisionNode = [_gameScene.rootNode childNodeWithName:@"Right" recursively:true];
  
  _pigNode.physicsBody.contactTestBitMask = BitMaskVehicle | BitMaskCoin | BitMaskHouse;
  
  _frontCollisionNode.physicsBody.contactTestBitMask  = BitMaskObstacle;
  _backCollisionNode.physicsBody.contactTestBitMask   = BitMaskObstacle;
  _leftCollisionNode.physicsBody.contactTestBitMask   = BitMaskObstacle;
  _rightCollisionNode.physicsBody.contactTestBitMask  = BitMaskObstacle;
}

- (void)setupActions {
  _driveLeftAction = [SCNAction repeatActionForever:[SCNAction moveBy:SCNVector3Make(-2.0, 0, 0) duration:1.0]];
  _driveRightAction = [SCNAction repeatActionForever:[SCNAction moveBy:SCNVector3Make(2.0, 0, 0) duration:1.0]];
  
  float duration = 0.2;
  
  SCNAction* bounceUpAction = [SCNAction moveBy:SCNVector3Make(0, 1.0, 0) duration:duration*0.5];
  SCNAction* bounceDownAction = [SCNAction moveBy:SCNVector3Make(0, -1.0, 0) duration:duration*0.5];
  
  bounceUpAction.timingMode = SKActionTimingEaseOut;
  bounceDownAction.timingMode = SKActionTimingEaseIn;
  
  SCNAction* bounceAction = [SCNAction sequence:@[bounceUpAction, bounceDownAction]];
  
  SCNAction* moveLeftAction = [SCNAction moveBy:SCNVector3Make(-1.0, 0, 0) duration:duration];
  SCNAction* moveRightAction = [SCNAction moveBy:SCNVector3Make(1.0, 0, 0) duration:duration];
  SCNAction* moveForwardAction = [SCNAction moveBy:SCNVector3Make(0, 0, -1.0) duration:duration];
  SCNAction* moveBackwardAction = [SCNAction moveBy:SCNVector3Make(0, 0, 1.0) duration:duration];
  
  SCNAction* turnLeftAction = [SCNAction rotateToX:0 y:convert_to_radians(-90) z:0 duration:duration shortestUnitArc:true];
  SCNAction* turnRightAction = [SCNAction rotateToX:0 y:convert_to_radians(90) z:0 duration:duration shortestUnitArc:true];
  SCNAction* turnForwardAction = [SCNAction rotateToX:0 y:convert_to_radians(180) z:0 duration:duration shortestUnitArc:true];
  SCNAction* turnBackwardAction = [SCNAction rotateToX:0 y:convert_to_radians(0) z:0 duration:duration shortestUnitArc:true];
  
  _jumpLeftAction = [SCNAction group:@[turnLeftAction, bounceAction, moveLeftAction]];
  _jumpRightAction = [SCNAction group:@[turnRightAction, bounceAction, moveRightAction]];
  _jumpForwardAction = [SCNAction group:@[turnForwardAction, bounceAction, moveForwardAction]];
  _jumpBackwardAction = [SCNAction group:@[turnBackwardAction, bounceAction, moveBackwardAction]];
  
  SCNAction* spinAround = [SCNAction rotateByX:0 y:convert_to_radians(720) z:0 duration:2.0];
  SCNAction* riseUp = [SCNAction moveBy:SCNVector3Make(0, 10, 0) duration:2.0];
  SCNAction* fadeOut = [SCNAction fadeOpacityTo:0 duration:2.0];
  
  SCNAction* goodByePig = [SCNAction group:@[spinAround, riseUp, fadeOut]];
  SCNAction* gameOver = [SCNAction runBlock:^(SCNNode * _Nonnull node) {
    self->_pigNode.position = SCNVector3Make(0, 0, 0);
    self->_pigNode.opacity = 1.0;
    [self startSplash];
  }];
  
  _triggerGameOver = [SCNAction sequence:@[goodByePig, gameOver]];
}

- (void)setupTraffic {
  for(SCNNode* node in _trafficNode.childNodes) {
    if([node.name containsString:@"Bus"])
    {
      _driveLeftAction.speed = 1.0;
      _driveRightAction.speed = 1.0;
    }
    else
    {
      _driveLeftAction.speed = 2.0;
      _driveRightAction.speed = 2.0;
    }
    
    if(node.eulerAngles.y > 0)
    {
      [node runAction:_driveLeftAction];
    }
    else
    {
      [node runAction:_driveRightAction];
    }
  }
}

- (void)setupGesture {
  
}

- (void)loadSounds {
  _music = [SCNAudioSource audioSourceNamed:@"MrPig.scnassets/Audio/Music.mp3"];
  
  _music.volume = 0.3;
  _music.loops = true;
  _music.shouldStream = true;
  _music.positional = false;
  
  _musicPlayer = [SCNAudioPlayer audioPlayerWithSource:_music];
  
  _traffic = [SCNAudioSource audioSourceNamed:@"MrPig.scnassets/Audio/Traffic.mp3"];
  
  _traffic.volume = 0.3;
  _traffic.loops = true;
  _traffic.shouldStream = true;
  _traffic.positional = true;
  
  _trafficPlayer = [SCNAudioPlayer audioPlayerWithSource:_traffic];
  
  [_game loadSoundName:@"Jump" FileNamed:@"MrPig.scnassets/Audio/Jump.wav"];
  [_game loadSoundName:@"Blocked" FileNamed:@"MrPig.scnassets/Audio/Blocked.wav"];
  [_game loadSoundName:@"Crash" FileNamed:@"MrPig.scnassets/Audio/Crash.wav"];
  [_game loadSoundName:@"CollectCoin" FileNamed:@"MrPig.scnassets/Audio/CollectCoin.wav"];
  [_game loadSoundName:@"BankCoin" FileNamed:@"MrPig.scnassets/Audio/BankCoin.wav"];
  
  [self setupSounds];
}

- (void)setupSounds {
  if(_game.state == TapToPlay)
  {
    [_splashScene.rootNode addAudioPlayer:_musicPlayer];
    //[_gameScene.rootNode removeAudioPlayer:_trafficPlayer]; ???
  }
  else if(_game.state == Playing)
  {
    [_gameScene.rootNode addAudioPlayer:_trafficPlayer];
    //[_splashScene.rootNode removeAudioPlayer:_musicPlayer]; ???
  }
}

- (void)handleTap:(NSGestureRecognizer *)gestureRecognizer {
  if(_game.state == TapToPlay) {
    [self startGame];
  }
}

- (void)startGame {
  _activeCollisionsBitMask = 0;
  
  _splashScene.paused = true;
  
  SKTransition* transition = [SKTransition doorsOpenVerticalWithDuration:1.0];
  
  [_view presentScene:_gameScene withTransition:transition incomingPointOfView:nil completionHandler:^void(void){
    self->_game.state = Playing;
    [self setupSounds];
    self->_gameScene.paused = false;
  }];
}

- (void)stopGame {
  _game.state = GameOver;
  [_game reset];
  
  [_pigNode runAction:_triggerGameOver];
}

- (void)startSplash {
  _gameScene.paused = true;
  
  SKTransition* transition = [SKTransition doorsOpenVerticalWithDuration:1.0];
  
  [_view presentScene:_splashScene withTransition:transition incomingPointOfView:nil completionHandler:^void(void){
    self->_game.state = TapToPlay;
    [self setupSounds];
    self->_splashScene.paused = false;
  }];
}

-(void)keyDown:(NSEvent *)theEvent {
  if(_game.state != Playing) {
    return;
  }
  
  int key = theEvent.keyCode;
  
  if((key == 123 && (_activeCollisionsBitMask & BitMaskLeft) != 0)    ||
     (key == 124 && (_activeCollisionsBitMask & BitMaskRight) != 0)   ||
     (key == 126 && (_activeCollisionsBitMask & BitMaskFront) != 0)   ||
     (key == 125 && (_activeCollisionsBitMask & BitMaskBack) != 0))
  {
    [_game playSound:_pigNode Name:@"Blocked"];
    return;
  }
  
  switch(key) {
    case 123:   // left
      if(_pigNode.position.x > -15)
      {
        [_pigNode runAction:_jumpLeftAction];
        [_game playSound:_pigNode Name:@"Jump"];
      }
      break;
      
    case 124:   // right
      if(_pigNode.position.x < 15)
      {
        [_pigNode runAction:_jumpRightAction];
        [_game playSound:_pigNode Name:@"Jump"];
      }
      break;
      
    case 126:   // up
      [_pigNode runAction:_jumpForwardAction];
      [_game playSound:_pigNode Name:@"Jump"];
      break;
      
    case 125:   // down
      [_pigNode runAction:_jumpBackwardAction];
      [_game playSound:_pigNode Name:@"Jump"];
      break;
      
    default:
      [super keyDown:theEvent];
      break;
  }
}

- (void)updatePositions {
  _collisionNode.position = _pigNode.position;
  
  SCNVector3 camPos = _cameraFollowNode.position;
  
  float lerpX = (_pigNode.position.x - camPos.x) * 0.05;
  float lerpZ = (_pigNode.position.z - camPos.z) * 0.05;
  
  camPos.x += lerpX;
  camPos.z += lerpZ;
  
  _cameraFollowNode.position = camPos;
  
  _lightFollowNode.position = _cameraFollowNode.position;
}

- (void)updateTraffic {
  SCNVector3 pos;
  
  for(SCNNode* node in _trafficNode.childNodes)
  {
    pos = node.position;
    
    if(pos.x > 25)
    {
      pos.x -= 50;
      node.position = pos;
    }
    else if(pos.x < -25)
    {
      pos.x += 50;
      node.position = pos;
    }
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
  if(_game.state != Playing)
  {
    return;
  }
  
  [_game updateHUD];
  [self updatePositions];
  [self updateTraffic];
}
@end

////////////////////////////////////////////////////////////////////////////////////////
//
// collision detection extension
//
////////////////////////////////////////////////////////////////////////////////////////
@implementation GameViewController (SCNPhysicsContactDelegate)
- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact {
  if(_game.state != Playing) {
    return;
  }
  
  SCNNode* collisionBoxNode = nil;
  
  if(contact.nodeA.physicsBody.categoryBitMask == BitMaskObstacle)
  {
    collisionBoxNode = contact.nodeB;
  }
  else if(contact.nodeB.physicsBody.categoryBitMask == BitMaskObstacle)
  {
    collisionBoxNode = contact.nodeA;
  }
  
  if(collisionBoxNode != nil)
  {
    _activeCollisionsBitMask |= collisionBoxNode.physicsBody.categoryBitMask;
  
    NSLog(@"collision begin %d", _activeCollisionsBitMask);
  }
  
  SCNNode* contactNode;
  
  if(contact.nodeA.physicsBody.categoryBitMask == BitMaskPig)
  {
    contactNode = contact.nodeB;
  }
  else
  {
    contactNode = contact.nodeA;
  }
  
  if(contactNode.physicsBody.categoryBitMask == BitMaskVehicle)
  {
    [self stopGame];
    [_game playSound:_pigNode Name:@"Crash"];
  }
  
  if(contactNode.physicsBody.categoryBitMask == BitMaskCoin)
  {
    contactNode.hidden = true;
    [contactNode runAction:[SCNAction waitForDuration:60 ThenRunBlock:^(SCNNode * _Nonnull node) {
      node.hidden = false;
    }]];
    [_game collectionCoin];
    [_game playSound:_pigNode Name:@"CollectCoin"];
  }
  
  if(contactNode.physicsBody.categoryBitMask == BitMaskHouse)
  {
    if([_game bankCoins] == true)
    {
      [_game playSound:_pigNode Name:@"BankCoin"];
    }
  }
}

- (void)physicsWorld:(SCNPhysicsWorld *)world didEndContact:(SCNPhysicsContact *)contact {
  if(_game.state != Playing) {
    return;
  }
  
  SCNNode* collisionBoxNode;
  
  if(contact.nodeA.physicsBody.categoryBitMask == BitMaskObstacle)
  {
    collisionBoxNode = contact.nodeB;
  }
  else
  {
    collisionBoxNode = contact.nodeA;
  }
  
  _activeCollisionsBitMask &= ~collisionBoxNode.physicsBody.categoryBitMask;
  
  NSLog(@"collision end %d", _activeCollisionsBitMask);
}
@end
