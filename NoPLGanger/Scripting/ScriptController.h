//
//  ScriptController.h
//  NoPLGanger
//
//  Created by Brad Bambara on 10/19/12.
//  Copyright (c) 2012 Brad Bambara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoPLScriptData.h"

typedef enum
{
	DebuggerState_NotRunning,
	DebuggerState_Running,
	DebuggerState_Paused,
}DebuggerState;

@interface ScriptController : NSObject <NSTextViewDelegate, NSTextFieldDelegate>
{
	IBOutlet NSTextView* scriptView;
	IBOutlet NSTextView* consoleView;
	IBOutlet NSTextField* debugInputView;
	IBOutlet NSButton* buildRunBtn;
	IBOutlet NSButton* buildBtn;
	IBOutlet NSButton* continueBtn;
	IBOutlet NSButton* stepBtn;
	IBOutlet NSButton* stopBtn;
	
	NSMutableDictionary* colors;
	
	NSTimer* recompileTimer;
	
	NSString* currentFilePath;
	
	DebuggerState debugState;
	NoPL_DebugHandle debugHandle;
	NoPL_Callbacks callbacks;
	int scriptExecutionLine;
	NSMutableArray* breakpoints;
	NSMutableArray* errorLines;
	NoPLScriptData* scriptVarData;
	NSMutableArray* commandHistory;
	NSUInteger commandHistoryIndex;
}
@end
