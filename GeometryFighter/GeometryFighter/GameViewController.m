//
//  GameViewController.m
//  GeometryFighter
//
//  Created by 김혁 on 19/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "GameViewController.h"
#import "ShapeTypes.h"
#import "NSColor+Extensions.h"
#import "SCNAction+Extensions.h"
#import "GameHelper.h"

#include "random_util.h"

@implementation GameViewController {
  SCNView*    _view;
  SCNScene*   _scene;
  SCNNode*    _cameraNode;
  NSTimeInterval  _spawnTime;
  GameHelper*     _game;
  NSMutableDictionary*    _splashes;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _game = [GameHelper sharedInstance];
  _spawnTime = 0;
  
  [self setupView];
  [self setupScene];
  [self setupCamera];
  [self setupHUD];
  [self setupSound];
  [self setupSplash];
  //[self spawnShapes];
  
  // Add a click gesture recognizer
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
  _scene = [SCNScene scene];
  _scene.background.contents = @"GeometryFighter.scnassets/Textures/Background_Diffuse.png";
  
  // _scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
  
  _view.scene = _scene;
}

- (void)setupCamera
{
  _cameraNode = [SCNNode node];
  _cameraNode.camera = [SCNCamera camera];
  _cameraNode.position = SCNVector3Make(0, 5, 10);
  
  [_scene.rootNode addChildNode:_cameraNode];
}

- (void)setupHUD {
  _game.hudNode.position = SCNVector3Make(0.0, 10.0, 0.0);
  [_scene.rootNode addChildNode:_game.hudNode];
}

- (void)setupSound {
  [_game loadSoundName:@"ExplodeGood" FileNamed:@"GeometryFighter.scnassets/Sounds/ExplodeGood.wav"];
  [_game loadSoundName:@"SpawnGood" FileNamed:@"GeometryFighter.scnassets/Sounds/SpawnGood.wav"];
  [_game loadSoundName:@"ExplodeBad" FileNamed:@"GeometryFighter.scnassets/Sounds/ExplodeBad.wav"];
  [_game loadSoundName:@"SpawnBad" FileNamed:@"GeometryFighter.scnassets/Sounds/SpawnBad.wav"];
  [_game loadSoundName:@"GameOver" FileNamed:@"GeometryFighter.scnassets/Sounds/GameOver.wav"];
}

- (SCNNode*)createSplash:(NSString*)name ImageFileName:(NSString*)imageFileName {
  /*
   let plane = SCNPlane(width: 5, height: 5)
   let splashNode = SCNNode(geometry: plane)
   splashNode.position = SCNVector3(x: 0, y: 5, z: 0)
   splashNode.name = name
   splashNode.geometry?.materials.first?.diffuse.contents = imageFileName
   scnScene.rootNode.addChildNode(splashNode)
   return splashNode
   */
  SCNPlane* plane = [SCNPlane planeWithWidth:5 height:5];
  SCNNode* splashNode = [SCNNode nodeWithGeometry:plane];
  
  splashNode.position = SCNVector3Make(0, 5, 0);
  splashNode.name = name;
  splashNode.geometry.materials.firstObject.diffuse.contents = imageFileName;
  [_scene.rootNode addChildNode:splashNode];
  
  return splashNode;
}

- (void)showSplash:(NSString*)name {
  for(NSString* key in _splashes)
  {
    SCNNode* node = _splashes[key];
    
    if([name isEqualToString:key])
    {
      [node setHidden:false];
    }
    else
    {
      [node setHidden:true];
    }
  }
}
- (void)setupSplash {
  _splashes = [NSMutableDictionary dictionary];
  
  _splashes[@"TapToPlay"] = [self createSplash:@"TAPTOPLAY" ImageFileName:@"GeometryFighter.scnassets/Textures/TapToPlay_Diffuse.png"];
  _splashes[@"GameOver"] = [self createSplash:@"GAMEOVER" ImageFileName:@"GeometryFighter.scnassets/Textures/GameOver_Diffuse.png"];
  
  [self showSplash:@"TapToPlay"];
}

- (void)spawnShapes
{
  SCNGeometry* geometry;
  
  switch(shapetypes_random())
  {
    case box:
      geometry = [SCNBox boxWithWidth:1.0 height:1.0 length:1.0 chamferRadius:0.0];
      break;
      
    case sphere:
      geometry = [SCNSphere sphereWithRadius:0.5];
      break;
      
    case pyramid:
      geometry = [SCNPyramid pyramidWithWidth:1.0 height:1.0 length:1.0];
      break;
      
    case torus:
      geometry = [SCNTorus torusWithRingRadius:0.5 pipeRadius:0.25];
      break;
      
    case capsule:
      geometry = [SCNCapsule capsuleWithCapRadius:0.3 height:2.5];
      break;
      
    case cylinder:
      geometry = [SCNCylinder cylinderWithRadius:0.3 height:2.5];
      break;
      
    case cone:
      geometry = [SCNCone coneWithTopRadius:0.25 bottomRadius:0.5 height:1.0];
      break;
      
    case tube:
      geometry = [SCNTube tubeWithInnerRadius:0.25 outerRadius:0.5 height:1.0];
      break;
  }
  
  SCNNode* geometryNode = [SCNNode nodeWithGeometry:geometry];
  geometryNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
  
  float randomX = float_random(-2, 2);
  float randomY = float_random(10, 18);
  
  SCNVector3 force = SCNVector3Make(randomX, randomY, 0);
  SCNVector3 position = SCNVector3Make(0.05, 0.05, 0.05);
  
  NSColor* color = [NSColor random];
  
  if([color compareWithColor:[NSColor blackColor]])
  {
    geometryNode.name = @"BAD";
    [_game playSound:_scene.rootNode Name:@"SpawnBad"];
  }
  else
  {
    geometryNode.name = @"GOOD";
    [_game playSound:_scene.rootNode Name:@"SpawnGood"];
  }
  
  [geometryNode.physicsBody applyForce:force atPosition:position impulse:true];
  geometry.materials.firstObject.diffuse.contents = color;
  
  SCNParticleSystem* trailEmitter = [self createTrail:color WithGeometry:geometry];
  
  [geometryNode addParticleSystem:trailEmitter];
  
  [_scene.rootNode addChildNode:geometryNode];
}

- (void)clearScene {
  for(SCNNode* node in _scene.rootNode.childNodes)
  {
    if(node.presentationNode.position.y < -2)
    {
      [node removeFromParentNode];
    }
  }
}

- (SCNParticleSystem*)createTrail:(NSColor*) color WithGeometry:(SCNGeometry*)geometry {
  SCNParticleSystem* trail;
  
  trail = [SCNParticleSystem particleSystemNamed:@"Trail.scnp" inDirectory:nil];
  
  trail.particleColor = color;
  trail.emitterShape = geometry;
  
  return trail;
}

- (void)handleGoodCollision {
  _game.score += 1;
  [_game playSound:_scene.rootNode Name:@"ExplodeGood"];
}

- (void)handleBadCollision {
  _game.lives -= 1;
  [_game playSound:_scene.rootNode Name:@"ExplodeBad"];
  [_game shakeNode:_cameraNode];
  
  if(_game.lives <= 0)
  {
    [_game saveState];
    [self showSplash:@"GameOver"];
    [_game playSound:_scene.rootNode Name:@"GameOver"];
    _game.state = GameOver;
    
    [_scene.rootNode runAction:[SCNAction waitForDuration:5 ThenRunBlock:^void(SCNNode * _Nonnull node) {
      [self showSplash:@"TapToPlay"];
      self->_game.state = TapToPlay;
    }]];
  }
}

- (void)handleTouchFor:(SCNNode*)node {
  if([node.name isEqualToString:@"HUD"] ||
     [node.name isEqualToString:@"GAMEOVER"] ||
     [node.name isEqualToString:@"TAPTOPLAY"])
  {
    return;
  }
  
  if([node.name isEqualToString:@"GOOD"]) {
    [self handleGoodCollision];
  } else if([node.name isEqualToString:@"BAD"]) {
    [self handleBadCollision];
  }
  
  [self createExplosion:node.geometry At:node.presentationNode.position ByRotate:node.presentationNode.rotation];
  [node removeFromParentNode];
}

- (void)createExplosion:(SCNGeometry*)geometry At:(SCNVector3)position ByRotate:(SCNVector4)rotation {
  SCNParticleSystem* explosion = [SCNParticleSystem particleSystemNamed:@"Explode.scnp" inDirectory:nil];
  
  explosion.emitterShape = geometry;
  explosion.birthLocation = SCNParticleBirthLocationSurface;
  
  SCNMatrix4 rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z);
  SCNMatrix4 translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z);
  SCNMatrix4 transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix);
  
  [_scene addParticleSystem:explosion withTransform:transformMatrix];
}

- (void)handleTap:(NSGestureRecognizer *)gestureRecognizer {
  if(_game.state == GameOver)
  {
    return;
  }
  
  if(_game.state == TapToPlay)
  {
    [_game reset];
    _game.state = Playing;
    [self showSplash:@""];
    return;
  }
  
  CGPoint p = [gestureRecognizer locationInView:_view];
  NSArray *hitResults = [_view hitTest:p options:nil];
  
  if([hitResults count] > 0)
  {
    SCNHitTestResult *result = [hitResults objectAtIndex:0];
    [self handleTouchFor:result.node];
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
}
@end
