//
//  ViewController.m
//  objc_lua
//
//  Created by 김혁 on 28/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//
// https://github.com/CrimsonMoonEntertainment/EasyLua/blob/master/Example/Tests/LuaTest.lua
// https://github.com/CrimsonMoonEntertainment/EasyLua/blob/master/Example/Tests/Tests.m
// https://github.com/simoncozens/NSLua
//

#import "ViewController.h"
#import "NSLua.h"

@implementation ViewController {
  NSLua* _lua;
  __weak IBOutlet NSTextField *_label;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Do any additional setup after loading the view.
  _lua = [NSLua sharedLua];
  
  [_lua runLuaBundleFile:@"scripts/obj_lua_test.lua"];
}


- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}

- (IBAction)test1Clicked:(NSButton *)sender {
  NSLog(@"test 1 clicked");
  
  [[NSLua sharedLua] runLuaString:@"print(\"Hello Test1\")"];
  [[NSLua sharedLua] runLuaBundleFile:@"scripts/test1.lua"];
  [[NSLua sharedLua] runLuaBundleFile:@"scripts/test_group/test2.lua"];
}

- (IBAction)helloWorldClicked:(NSButton *)sender {
  [_lua callLuaFunction:@"hello_world" withArguments:nil];
  
  NSString* str = [_lua callLuaFunction:@"give_me_string" withArguments:@[@"Bokdol"]];
  
  NSLog(@"got \"%@\" from lua script", str);
}
- (IBAction)testCallbackClicked:(id)sender {
  [_lua callLuaFunction:@"callback_test" withArguments:@[self, @"Callback test performed!"]];
}

- (void)helloWorld:(NSString*)str {
  [_label setStringValue:str];
}

- (IBAction)testDirectAccessClicked:(NSButton *)sender {
  [_lua callLuaFunction:@"direct_property_access" withArguments:@[self]];
}
@end
