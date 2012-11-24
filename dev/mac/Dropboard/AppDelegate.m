//
//  AppDelegate.m
//  Dropboard
//
//  Created by daichi on 12/11/24.
//  Copyright (c) 2012年 501dev.org. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate {
    NSTask *_nodeTask;
    BOOL _alreadyActivated;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSString *workDir = [bundle pathForResource:@"node" ofType:@""];
    NSLog(@"workDir = %@", workDir);
    
    NSString *nodePath = [workDir stringByAppendingPathComponent:@"node_"];
    NSString *scriptPath = [workDir stringByAppendingPathComponent:@"server.js"];
    
    _nodeTask = [[NSTask alloc] init];
    
    _nodeTask.launchPath = nodePath;
    _nodeTask.arguments = @[ scriptPath ];
    _nodeTask.standardOutput = [NSPipe pipe];
    
    [_nodeTask launch];
    
    NSFileHandle *outputHandle = [_nodeTask.standardOutput fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readData:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:outputHandle];
    [outputHandle readInBackgroundAndNotify];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [_nodeTask terminate];
    _nodeTask = nil;
}

- (void)readData:(NSNotification *)note {
    NSData *data = [note.userInfo objectForKey:NSFileHandleNotificationDataItem];
    NSString *url = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    _boardUrl = url;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (_alreadyActivated == NO) {
        _alreadyActivated = YES;
        
    } else {
        [self openBoard];
    }
}

- (void)openBoard {
    if ([_boardUrl length]) {
        NSString *cmd = [NSString stringWithFormat:@"open %@", _boardUrl];
        system([cmd UTF8String]);
    }
}

@end
