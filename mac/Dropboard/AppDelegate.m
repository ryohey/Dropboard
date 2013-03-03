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
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    
    NSString *workDir = [bundle pathForResource:@"node" ofType:@""];
    
    NSString *nodePath = [workDir stringByAppendingPathComponent:@"node_"];
    NSString *scriptPath = [workDir stringByAppendingPathComponent:@"../src/server.js"];
    
    _nodeTask = [[NSTask alloc] init];
    
    _nodeTask.currentDirectoryPath = workDir;
    _nodeTask.launchPath = nodePath;
    _nodeTask.arguments = @[ scriptPath ];
    
    _nodeTask.standardOutput = [NSPipe pipe];
    
    [[NSFileManager defaultManager] setAttributes:@{NSFilePosixPermissions: @757} ofItemAtPath:nodePath error:nil];
    
    // node の終了を監視
    [noteCenter addObserver:self
                   selector:@selector(nodeDidTerminate:)
                       name:NSTaskDidTerminateNotification
                     object:_nodeTask];
    
    // node の標準出力を監視
    NSFileHandle *outputHandle = [_nodeTask.standardOutput fileHandleForReading];
    [noteCenter addObserver:self
                   selector:@selector(nodeOutputDidReadComplete:)
                       name:NSFileHandleReadCompletionNotification
                     object:outputHandle];
    [outputHandle readInBackgroundAndNotify];

    // 起動
    [_nodeTask launch];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // アプリ終了時に node も終了する (通知が発生するのでこの前に監視を解除する)
    [_nodeTask terminate];
    _nodeTask = nil;
}

/**
 * node プロセスが終了した時に呼ばれる.
 * <p>アプリ自体を終了する.</p>
 */
- (void)nodeDidTerminate:(NSNotification *)note {
    [[NSApplication sharedApplication] terminate:self];
}

/**
 * node の標準出力を取得できるようになった時に呼ばれる.
 */
- (void)nodeOutputDidReadComplete:(NSNotification *)note {
    NSData *data = [note.userInfo objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // 末尾の改行を削除
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (_boardUrl == nil) {
        // 1行目の出力は Dropboard ページの URL
        _boardUrl = str;
    }
    
    NSLog(@"%@",_boardUrl);
    [self openBoard];
}

/**
 * 初回起動、または Dock アイコンクリック時に呼ばれる.
 * <p>Dock アイコンがクリックされたら -openBoard を実行する.
 * </p>
 */
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (_alreadyActivated == NO) {
        // 初回起動時はサーバ起動後に開く
        _alreadyActivated = YES;
        
    } else {
        [self openBoard];
    }
}

/**
 * ブラウザで Dropboard ページを開く.
 */
- (void)openBoard {
    if ([_boardUrl length]) {
        NSString *cmd = [NSString stringWithFormat:@"open %@", _boardUrl];
        system([cmd UTF8String]);
    }
}

@end
