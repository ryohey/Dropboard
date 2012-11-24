//
//  AppDelegate.h
//  Dropboard
//
//  Created by daichi on 12/11/24.
//  Copyright (c) 2012年 501dev.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSString *boardUrl;

- (void)openBoard;

@end
