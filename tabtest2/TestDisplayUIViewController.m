//
//  TestDisplayUIViewController.m
//  tabtest
//
//  Created by Shiny Yang on 9/3/15.
//  Copyright (c) 2015 spotco. All rights reserved.
//

#import "TestDisplayUIViewController.h"
#import "ICRootViewController.h"
#import "ICEmojiTextureCache.h"

@implementation TestDisplayUIViewController {
    ICRootViewController *_control_view;
}

static TestDisplayUIViewController *_inst;

-(void)viewDidAppear:(BOOL)animated {
    [[ICEmojiTextureCache instance] add_image:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://spotcos.com/et/highfive.png"]]] for_name:@"HighFive1"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive2"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive3"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive4"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive5"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive6"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive7"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive8"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive9"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive10"];
    [[ICEmojiTextureCache instance] add_image:[[ICEmojiTextureCache instance] get_image_for_name:@"HighFive1"] for_name:@"HighFive11"];
    _inst = self;
    NSLog(@"testdisplayuiviewcontroller appear");
    self.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.8 alpha:1.0];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 280.0f, 124.0f)];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.text = @"press to toggle control bar";
    [textView sizeToFit];
    textView.editable = NO;
    textView.selectable = NO;
    
    [self.view addSubview:textView];
    
    [textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(show_controls)]];
	
	
	textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 60.0f, 280.0f, 124.0f)];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.text = @"load test json";
    [textView sizeToFit];
    textView.editable = NO;
    textView.selectable = NO;
	[self.view addSubview:textView];
	[textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(load_test_json)]];
	
	textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 100.0f, 280.0f, 124.0f)];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.text = @"print json";
    [textView sizeToFit];
    textView.editable = NO;
    textView.selectable = NO;
	[self.view addSubview:textView];
	[textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(print_json)]];
	
    _control_view = [[ICRootViewController alloc] init];
    _control_view.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _control_view.view.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0];
    [self addChildViewController:_control_view];
    [self.view addSubview:_control_view.view];
    
    
    //[KeyboardDelegate Initialize];
    
}

static bool __TEST = NO;
-(void)show_controls {
	__TEST = !__TEST;
	[_control_view toggle_native_control_ui:__TEST];
}

-(void)load_test_json {
	[_control_view load_message_json:@"[{\"type\": \"text\", \"val\": \"Hi\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"text\", \"val\": \"Bye\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"text\", \"val\": \"Bye\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"text\", \"val\": \"Bye\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"text\", \"val\": \"Bye\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"emoji\", \"val\": \"HighFive\"}, {\"type\": \"text\", \"val\": \"Bye\"}]"];
}

-(void)print_json {
	NSLog(@"-----print_json");
	NSLog(@"%@",[_control_view out_message_json]);
	NSLog(@"-----");
}

+(UIView*)get_view {
    return _inst.view;
}


-(BOOL)prefersStatusBarHidden { return YES; }

@end
