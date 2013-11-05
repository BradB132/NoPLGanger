//
//  ScriptController.m
//  NoPLGanger
//
//  Created by Brad Bambara on 10/19/12.
//  Copyright (c) 2012 Brad Bambara. All rights reserved.
//

#import "ScriptController.h"
#import "FileBrowserController.h"
#import "DataManager.h"
#import "NoPLRuntime.h"
#import "NoPLc.h"

#define kScriptController_CompileDelay 0.3
#define kScriptController_CodeFont @"Menlo"
#define kScriptController_CodeSize 11
#define kScriptController_MaxCommandHistory 50

#pragma mark - Enum conversion

NSString* tokenRangeTypeToString(NoPL_TokenRangeType type)
{
	switch(type)
	{
		case NoPL_TokenRangeType_numericLiterals:
			return @"numericLiterals";
		case NoPL_TokenRangeType_stringLiterals:
			return @"stringLiterals";
		case NoPL_TokenRangeType_booleanLiterals:
			return @"booleanLiterals";
		case NoPL_TokenRangeType_pointerLiterals:
			return @"pointerLiterals";
		case NoPL_TokenRangeType_controlFlowKeywords:
			return @"controlFlowKeywords";
		case NoPL_TokenRangeType_typeKeywords:
			return @"typeKeywords";
		case NoPL_TokenRangeType_operators:
			return @"operators";
		case NoPL_TokenRangeType_variables:
			return @"variables";
		case NoPL_TokenRangeType_functions:
			return @"functions";
		case NoPL_TokenRangeType_syntax:
			return @"syntax";
		case NoPL_TokenRangeType_comments:
			return @"comments";
		case NoPL_TokenRangeType_metadata:
			return @"metadata";
		default:
			return nil;
	}
}

NSString* noplInstructionToString(NoPL_Instruction instruction)
{
	switch(instruction)
	{
		case NoPL_BYTE_BOOLEAN_TABLE_SIZE:
			return @"BOOLEAN_TABLE_SIZE";
		case NoPL_BYTE_NUMERIC_TABLE_SIZE:
			return @"NUMERIC_TABLE_SIZE";
		case NoPL_BYTE_STRING_TABLE_SIZE:
			return @"STRING_TABLE_SIZE";
		case NoPL_BYTE_OBJECT_TABLE_SIZE:
			return @"OBJECT_TABLE_SIZE";
		case NoPL_BYTE_LITERAL_NUMBER:
			return @"LITERAL_NUMBER";
		case NoPL_BYTE_LITERAL_BOOLEAN_TRUE:
			return @"LITERAL_BOOLEAN_TRUE";
		case NoPL_BYTE_LITERAL_BOOLEAN_FALSE:
			return @"LITERAL_BOOLEAN_FALSE";
		case NoPL_BYTE_LITERAL_STRING:
			return @"LITERAL_STRING";
		case NoPL_BYTE_LITERAL_NULL:
			return @"LITERAL_NULL";
		case NoPL_BYTE_VARIABLE_NUMBER:
			return @"VARIABLE_NUMBER";
		case NoPL_BYTE_VARIABLE_BOOLEAN:
			return @"VARIABLE_BOOLEAN";
		case NoPL_BYTE_VARIABLE_STRING:
			return @"VARIABLE_STRING";
		case NoPL_BYTE_VARIABLE_OBJECT:
			return @"VARIABLE_OBJECT";
		case NoPL_BYTE_NUMERIC_ADD:
			return @"NUMERIC_ADD";
		case NoPL_BYTE_NUMERIC_SUBTRACT:
			return @"NUMERIC_SUBTRACT";
		case NoPL_BYTE_NUMERIC_DIVIDE:
			return @"NUMERIC_DIVIDE";
		case NoPL_BYTE_NUMERIC_MULTIPLY:
			return @"NUMERIC_MULTIPLY";
		case NoPL_BYTE_NUMERIC_EXPONENT:
			return @"NUMERIC_EXPONENT";
		case NoPL_BYTE_NUMERIC_MODULO:
			return @"NUMERIC_MODULO";
		case NoPL_BYTE_NUMERIC_INCREMENT:
			return @"NUMERIC_INCREMENT";
		case NoPL_BYTE_NUMERIC_DECREMENT:
			return @"NUMERIC_DECREMENT";
		case NoPL_BYTE_NUMERIC_ASSIGN:
			return @"NUMERIC_ASSIGN";
		case NoPL_BYTE_NUMERIC_ADD_ASSIGN:
			return @"NUMERIC_ADD_ASSIGN";
		case NoPL_BYTE_NUMERIC_SUBTRACT_ASSIGN:
			return @"NUMERIC_SUBTRACT_ASSIGN";
		case NoPL_BYTE_NUMERIC_DIVIDE_ASSIGN:
			return @"NUMERIC_DIVIDE_ASSIGN";
		case NoPL_BYTE_NUMERIC_MULTIPLY_ASSIGN:
			return @"NUMERIC_MULTIPLY_ASSIGN";
		case NoPL_BYTE_NUMERIC_EXPONENT_ASSIGN:
			return @"NUMERIC_EXPONENT_ASSIGN";
		case NoPL_BYTE_NUMERIC_MODULO_ASSIGN:
			return @"NUMERIC_MODULO_ASSIGN";
		case NoPL_BYTE_NUMERIC_ABS_VALUE:
			return @"NUMERIC_ABS_VALUE";
		case NoPL_BYTE_NUMERIC_NEGATION:
			return @"NUMERIC_NEGATION";
		case NoPL_BYTE_NUMERIC_LOGICAL_EQUALITY:
			return @"NUMERIC_LOGICAL_EQUALITY";
		case NoPL_BYTE_NUMERIC_LOGICAL_INEQUALITY:
			return @"NUMERIC_LOGICAL_INEQUALITY";
		case NoPL_BYTE_BOOLEAN_LOGICAL_EQUALITY:
			return @"BOOLEAN_LOGICAL_EQUALITY";
		case NoPL_BYTE_BOOLEAN_LOGICAL_INEQUALITY:
			return @"BOOLEAN_LOGICAL_INEQUALITY";
		case NoPL_BYTE_BOOLEAN_AND:
			return @"BOOLEAN_AND";
		case NoPL_BYTE_BOOLEAN_OR:
			return @"BOOLEAN_OR";
		case NoPL_BYTE_BOOLEAN_LESS_THAN:
			return @"BOOLEAN_LESS_THAN";
		case NoPL_BYTE_BOOLEAN_LESS_THAN_EQUAL:
			return @"BOOLEAN_LESS_THAN_EQUAL";
		case NoPL_BYTE_BOOLEAN_GREATER_THAN:
			return @"BOOLEAN_GREATER_THAN";
		case NoPL_BYTE_BOOLEAN_GREATER_THAN_EQUAL:
			return @"BOOLEAN_GREATER_THAN_EQUAL";
		case NoPL_BYTE_BOOLEAN_NEGATION:
			return @"BOOLEAN_NEGATION";
		case NoPL_BYTE_BOOLEAN_ASSIGN:
			return @"BOOLEAN_ASSIGN";
		case NoPL_BYTE_STRING_LOGICAL_EQUALITY:
			return @"STRING_LOGICAL_EQUALITY";
		case NoPL_BYTE_STRING_LOGICAL_INEQUALITY:
			return @"STRING_LOGICAL_INEQUALITY";
		case NoPL_BYTE_STRING_CONCAT:
			return @"STRING_CONCAT";
		case NoPL_BYTE_STRING_ASSIGN:
			return @"STRING_ASSIGN";
		case NoPL_BYTE_STRING_CONCAT_ASSIGN:
			return @"STRING_CONCAT_ASSIGN";
		case NoPL_BYTE_STRING_PRINT:
			return @"STRING_PRINT";
		case NoPL_BYTE_OBJECT_LOGICAL_EQUALITY:
			return @"OBJECT_LOGICAL_EQUALITY";
		case NoPL_BYTE_OBJECT_LOGICAL_INEQUALITY:
			return @"OBJECT_LOGICAL_INEQUALITY";
		case NoPL_BYTE_OBJECT_ASSIGN:
			return @"OBJECT_ASSIGN";
		case NoPL_BYTE_FUNCTION_CALL:
			return @"FUNCTION_CALL";
		case NoPL_BYTE_FUNCTION_INDEX:
			return @"FUNCTION_INDEX";
		case NoPL_BYTE_ARG_NUMBER:
			return @"ARG_NUMBER";
		case NoPL_BYTE_ARG_STRING:
			return @"ARG_STRING";
		case NoPL_BYTE_ARG_BOOLEAN:
			return @"ARG_BOOLEAN";
		case NoPL_BYTE_ARG_OBJECT:
			return @"ARG_OBJECT";
		case NoPL_BYTE_CONDITIONAL:
			return @"CONDITIONAL";
		case NoPL_BYTE_SWITCH_CASE_BOOLEAN:
			return @"SWITCH_CASE_BOOLEAN";
		case NoPL_BYTE_SWITCH_CASE_NUMBER:
			return @"SWITCH_CASE_NUMBER";
		case NoPL_BYTE_SWITCH_CASE_STRING:
			return @"SWITCH_CASE_STRING";
		case NoPL_BYTE_BUFFER_MOVE_FORWARD:
			return @"BUFFER_MOVE_FORWARD";
		case NoPL_BYTE_BUFFER_MOVE_BACKWARD:
			return @"BUFFER_MOVE_BACKWARD";
		case NoPL_BYTE_PROGRAM_EXIT:
			return @"PROGRAM_EXIT";
		case NoPL_BYTE_RESOLVE_RESULT_TO_NUMBER:
			return @"RESOLVE_RESULT_TO_NUMBER";
		case NoPL_BYTE_RESOLVE_RESULT_TO_BOOLEAN:
			return @"RESOLVE_RESULT_TO_BOOLEAN";
		case NoPL_BYTE_RESOLVE_RESULT_TO_STRING:
			return @"RESOLVE_RESULT_TO_STRING";
		case NoPL_BYTE_RESOLVE_RESULT_TO_OBJECT:
			return @"RESOLVE_RESULT_TO_OBJECT";
		case NoPL_BYTE_CAST_NUMBER_TO_BOOLEAN:
			return @"CAST_NUMBER_TO_BOOLEAN";
		case NoPL_BYTE_CAST_NUMBER_TO_STRING:
			return @"CAST_NUMBER_TO_STRING";
		case NoPL_BYTE_CAST_BOOLEAN_TO_NUMBER:
			return @"CAST_BOOLEAN_TO_NUMBER";
		case NoPL_BYTE_CAST_BOOLEAN_TO_STRING:
			return @"CAST_BOOLEAN_TO_STRING";
		case NoPL_BYTE_CAST_STRING_TO_NUMBER:
			return @"CAST_STRING_TO_NUMBER";
		case NoPL_BYTE_CAST_STRING_TO_BOOLEAN:
			return @"CAST_STRING_TO_BOOLEAN";
		case NoPL_BYTE_CAST_OBJECT_TO_STRING:
			return @"CAST_OBJECT_TO_STRING";
		case NoPL_BYTE_METADATA:
			return @"METADATA";
		case NoPL_BYTE_DEBUG_LINE:
			return @"DEBUG_LINE";
		case NoPL_BYTE_DEBUG_VALUE_NUMBER:
			return @"DEBUG_VALUE_NUMBER";
		case NoPL_BYTE_DEBUG_VALUE_BOOLEAN:
			return @"DEBUG_VALUE_BOOLEAN";
		case NoPL_BYTE_DEBUG_VALUE_STRING:
			return @"DEBUG_VALUE_STRING";
		case NoPL_BYTE_DEBUG_VALUE_OBJECT:
			return @"DEBUG_VALUE_OBJECT";
		default:
			return @"";
	}
}

@implementation ScriptController

-(void)setDebugState:(DebuggerState)newState
{
	//bail if this is not a real change
	if(newState == debugState)
		return;
	
	//disable all buttons
	[buildRunBtn setEnabled:NO];
	[buildBtn setEnabled:NO];
	[continueBtn setEnabled:NO];
	[stepBtn setEnabled:NO];
	[stopBtn setEnabled:NO];
	
	//we'll want to redo highlighting
	[self updateScriptHighlights];
	
	switch(newState)
	{
		case DebuggerState_NotRunning:
			
			[buildRunBtn setEnabled:YES];
			[buildBtn setEnabled:YES];
			
			//remove the script data
			if(scriptVarData)
			{
				[[DataManager sharedInstance] removeDataObject:scriptVarData];
				scriptVarData = NULL;
			}
			
			break;
		case DebuggerState_Running:
			
			//set up a script data
			if(!scriptVarData)
			{
				scriptVarData = [[NoPLScriptData alloc] initWithPath:currentFilePath andHandle:debugHandle];
				[[DataManager sharedInstance] addDataObject:scriptVarData];
			}
			
			break;
		case DebuggerState_Paused:
			
			[continueBtn setEnabled:YES];
			[stepBtn setEnabled:YES];
			[stopBtn setEnabled:YES];
			
			break;
	}
	
	debugState = newState;
}

+(NSColor*)colorWithHexColorString:(NSString*)inColorString
{
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
	
    if (nil != inColorString)
    {
		NSScanner* scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
	
    result = [NSColor
			  colorWithCalibratedRed:(CGFloat)redByte / 0xff
			  green:(CGFloat)greenByte / 0xff
			  blue:(CGFloat)blueByte / 0xff
			  alpha:1.0];
	return result;
}

-(void)awakeFromNib
{
	[scriptView setDelegate:self];
	
	//set fixed width font for all coding text views
	NSFont* codeFont = [NSFont fontWithName:kScriptController_CodeFont size:kScriptController_CodeSize];
	[scriptView setFont:codeFont];
	[consoleView setFont:codeFont];
	[debugInputView setFont:codeFont];
	
	//set up the debugger
	[self setDebugState:DebuggerState_NotRunning];
	breakpoints = [NSMutableArray array];
	debugHandle = NULL;
	callbacks = [DataManager callbacks];
	scriptExecutionLine = -1;
	commandHistory = [NSMutableArray array];
	commandHistoryIndex = 0;
	[debugInputView setDelegate:self];
	
	//create a list of colors from plist
	NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"EditorColors" ofType:@"plist"];
	NSDictionary* stringColors = [NSDictionary dictionaryWithContentsOfFile:dataPath];
	colors = [NSMutableDictionary dictionaryWithCapacity:[stringColors count]];
	for(NSString* key in [stringColors allKeys])
	{
		NSString* stringColor = [stringColors objectForKey:key];
		[colors setObject:[ScriptController colorWithHexColorString:stringColor] forKey:key];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scriptFileWasAdded:) name:kFileBroswer_SelectedScript object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scriptDidOutput:) name:kNoPL_ConsoleOutputNotification object:NULL];
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)saveCurrentScript
{
	if(currentFilePath)
		[[scriptView string] writeToFile:currentFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - Script logic

-(void)appendToConsole:(NSString*)output
{
	//apend the string to the console
	output = [NSString stringWithFormat:@"%@\n", output];
	NSAttributedString* attrCommand = [[NSAttributedString alloc] initWithString:output];
	NSTextStorage *storage = [consoleView textStorage];
	
	[storage beginEditing];
	[storage appendAttributedString:attrCommand];
	[storage endEditing];
}

-(void)endExecution
{
	if(debugHandle)
	{
		//clean up the script
		freeNoPL_DebugHandle(debugHandle);
		debugHandle = NULL;
		
		//reset current line
		scriptExecutionLine = -1;
		
		//switch state back to normal
		[self setDebugState:DebuggerState_NotRunning];
		
		//show some feedback
		[self appendToConsole:@"Script execution finished."];
	}
}

-(void)stepScript:(BOOL)continueToEnd
{
	if(!debugHandle)
		return;
	
	//set a running state for the debugger
	[self setDebugState:DebuggerState_Running];
	
	//step the script
	int okToContinue = 1;
	while(okToContinue && debugState == DebuggerState_Running)
	{
		okToContinue = debugStep(debugHandle);
		if(!continueToEnd)
		{
			[self setDebugState:DebuggerState_Paused];
			break;
		}
	}
	
	//cleanup if we actually finished the script
	if(!okToContinue)
	{
		[self endExecution];
	}
}

-(void)processDebugCommand:(NSString*)stringCommand
{
	//trim the string
	stringCommand = [stringCommand stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	//check for breakpoint command
	if([stringCommand hasPrefix:@"breakpoint "] ||
	   [stringCommand hasPrefix:@"break "] ||
	   [stringCommand hasPrefix:@"b "])
	{
		//parse the line argument
		NSRange spaceRange = [stringCommand rangeOfString:@" "];
		NSString* argString = [stringCommand substringFromIndex:spaceRange.location+1];
		
		if([argString isEqualToString:@"c"] ||
		   [argString isEqualToString:@"clear"])
		{
			[breakpoints removeAllObjects];
		}
		else
		{
			//this arg should be numeric
			int lineArg = [argString intValue];
			
			//check if this line is already in breakpoints list
			NSNumber* lineNum = [NSNumber numberWithInt:lineArg];
			if([breakpoints containsObject:lineNum])
			{
				[breakpoints removeObject:lineNum];
				[self appendToConsole:[NSString stringWithFormat:@"Breakpoint at line %d was removed.", lineArg]];
			}
			else
			{
				[breakpoints addObject:lineNum];
				[self appendToConsole:[NSString stringWithFormat:@"Breakpoint was added at line %d.", lineArg]];
			}
		}
		
		[self updateScriptHighlights];
		
		return;
	}
	
	//Xcode debugging has left me with the habbit of prefixing everything with 'p ', remove this if it's there
	if([stringCommand hasPrefix:@"po "] ||
	   [stringCommand hasPrefix:@"p "])
	{
		NSRange spaceRange = [stringCommand rangeOfString:@" "];
		stringCommand = [stringCommand substringFromIndex:spaceRange.location+1];
	}
	
	//format the string as a new script to query the current script
	stringCommand = [NSString stringWithFormat:@"#%@;", stringCommand];
	
	//debug commands should be interpreted as script, attempt to compile
	NoPL_CompileContext ctx = newNoPL_CompileContext();
	NoPL_CompileOptions options = NoPL_CompileOptions();
	options.optimizeForRuntime = 0;
	compileContextWithString([stringCommand UTF8String], &options, &ctx);
	
	//check if the compile succeded
	if(!ctx.errDescriptions)
	{
		//run the script
		runScript(ctx.compiledData, ctx.dataLength, &callbacks);
	}
	else
	{
		//show the compile error in the console
		NSString* error = [NSString stringWithUTF8String:ctx.errDescriptions];
		error = [error stringByReplacingOccurrencesOfString:@" (line 1)" withString:@""];
		[self appendToConsole:error];
	}
	
	//cleanup
	freeNoPL_CompileContext(&ctx);
}

-(void)clearConsole
{
	[[consoleView textStorage] deleteCharactersInRange:NSMakeRange(0, [[consoleView textStorage] length])];
}

-(void)updateDebugInputToCurrentIndex
{
	//use an empty string if out of range
	NSString* restoredDebugInput = nil;
	if(commandHistoryIndex >= [commandHistory count])
		restoredDebugInput = @"";
	else
	{
		//get the string from the history
		restoredDebugInput = [commandHistory objectAtIndex:commandHistoryIndex];
	}
	
	//update the debug prompt
	[debugInputView setStringValue:restoredDebugInput];
}

#pragma mark - Text formatting

-(NSRange)rangeForLine:(int)lineNum
{
	//go line by line to get the range
	NSString* scriptStr = [scriptView string];
	NSRange searchRange = NSMakeRange(0, [scriptStr length]);
	NSRange searchResult;
	NSRange highlightRange;
	for(int i = 0; i < lineNum; i++)
	{
		searchResult = [scriptStr rangeOfString:@"\n" options:NSLiteralSearch range:searchRange];
		
		//we don't have that many lines
		if(searchResult.location == NSNotFound)
			return searchResult;
		
		//get the range for this line
		highlightRange.location = searchRange.location;
		highlightRange.length = searchResult.location-searchRange.location;
		
		//narrow the search
		searchRange.location = searchResult.location+1;
		searchRange.length = [scriptStr length]-searchRange.location;
	}
	
	return highlightRange;
}

-(void)updateScriptHighlights
{
	//clear any previous highlights
	NSLayoutManager* layoutManager = [scriptView layoutManager];
	NSRange allTextRange = NSMakeRange(0, [[scriptView string] length]);
	[layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:allTextRange];
	[layoutManager removeTemporaryAttribute:NSUnderlineStyleAttributeName forCharacterRange:allTextRange];
	
	if([breakpoints count] > 0)
	{
		//set up the attributes for highlighting the background
		NSDictionary* breakpointAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
											  [colors objectForKey:@"breakpoints"], NSBackgroundColorAttributeName,
											  nil];
		
		//highlight each breakpoint
		for(NSNumber* num in breakpoints)
		{
			int lineNum = [num intValue];
			if(lineNum != scriptExecutionLine)
				[layoutManager setTemporaryAttributes:breakpointAttributes forCharacterRange:[self rangeForLine:lineNum]];
		}
	}
	
	if(scriptExecutionLine >= 0)
	{
		//set up the attributes for highlighting the background
		NSMutableDictionary* currentLineAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
													  [NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,
													  nil];
		
		if([breakpoints containsObject:[NSNumber numberWithInt:scriptExecutionLine]])
		{
			[currentLineAttributes setObject:[colors objectForKey:@"breakpoints"] forKey:NSBackgroundColorAttributeName];
		}
		
		[layoutManager setTemporaryAttributes:currentLineAttributes forCharacterRange:[self rangeForLine:scriptExecutionLine]];
	}
}

-(NSString*)compileScript
{
	//clear the console before we show anything for this new script
	[self clearConsole];
	
	//get the script from the text view
	NSString* script = [scriptView string];
	NSTextStorage* scriptStore = [scriptView textStorage];
	[scriptStore beginEditing];
	
	//set up objects for compilation
	NoPL_CompileContext ctx = newNoPL_CompileContext();
	NoPL_CompileOptions options = NoPL_CompileOptions();
	options.createTokenRanges = 1;
	options.debugSymbols = 1;
	options.optimizeForRuntime = 0;
	
	//compile the script
	compileContextWithString([script UTF8String], &options, &ctx);
	
	//check if the compile succeded
	NSString* outputPath = NULL;
	if(!ctx.errDescriptions)
	{
		//find the path for the output file
		outputPath = [[currentFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"noplb"];
		
		//save the script to file
		NSData* compiledData = [NSData dataWithBytes:ctx.compiledData length:ctx.dataLength];
		[compiledData writeToFile:outputPath atomically:YES];
		
		//set text color for background
		NSColor* bgColor = [colors objectForKey:@"background"];
		[scriptView setBackgroundColor:bgColor];
		NSColor* oppositeColor = [NSColor colorWithCalibratedRed:1-bgColor.redComponent green:1-bgColor.greenComponent blue:1-bgColor.blueComponent alpha:1];
		[scriptView setTextColor:oppositeColor];
		
		//evaluate colors for highlighting the sript
		for(int i = 0; i < NoPL_TokenRangeType_count; i++)
		{
			//get the next color
			NSColor* highlightColor = [colors objectForKey:tokenRangeTypeToString(i)];
			if(!highlightColor)
				continue;
			
			//highlight each range
			if(ctx.tokenRanges->counts[i] > 0)
			{
				for(int j = 0; j < ctx.tokenRanges->counts[i]; j++)
				{
					NoPL_TokenRange range = ctx.tokenRanges->ranges[i][j];
					[scriptView setTextColor:highlightColor range:NSMakeRange(range.startIndex, (range.endIndex-range.startIndex))];
				}
			}
		}
		[self appendToConsole:@"Build Succeeded"];
	}
	else
	{
		//show the compile error in the console
		[self appendToConsole:[NSString stringWithUTF8String:ctx.errDescriptions]];
	}
	
	freeNoPL_CompileContext(&ctx);
	
	[scriptStore endEditing];
	
	return outputPath;
}

-(void)handleDebugOutput:(NSString*)debugString
{
	//break all args into strings
	NSRange range = [debugString rangeOfString:@":"];
	NSArray* stringArgs = [[debugString substringFromIndex:range.location+1] componentsSeparatedByString:@","];
	NSMutableDictionary* debugArgs = [NSMutableDictionary dictionary];
	for(NSString* argString in stringArgs)
	{
		NSArray* pair = [argString componentsSeparatedByString:@"="];
		if([pair count] != 2)
			continue;
		[debugArgs setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
	}
	
	//check the type of debug output
	if([debugString hasPrefix:@"Line:"])
	{
		//get the line number that we're executing
		int lineNum = [[debugArgs objectForKey:@"line"] intValue];
		
		//store the last line
		int prevExecutionLine = scriptExecutionLine;
		scriptExecutionLine = lineNum;
		
		//check if there is a breakpoint on this line
		for(NSNumber* num in breakpoints)
		{
			int intVal = [num intValue];
			if(intVal > prevExecutionLine && intVal <= lineNum)
			{
				[self appendToConsole:[NSString stringWithFormat:@"Stopped at breakpoint on line %d", lineNum]];
				[self setDebugState:DebuggerState_Paused];
			}
		}
	}
	
	//check if the script has a data object (should have one if it's running)
	if(scriptVarData)
	{
		int index = -1;
		NSString* name = nil;
		NoPL_DataType type;
		if([debugString hasPrefix:@"Pointer:"])
		{
			index = [[debugArgs objectForKey:@"index"] intValue];
			name = [debugArgs objectForKey:@"name"];
			type = NoPL_DataType_Pointer;
		}
		else if([debugString hasPrefix:@"Boolean:"])
		{
			index = [[debugArgs objectForKey:@"index"] intValue];
			name = [debugArgs objectForKey:@"name"];
			type = NoPL_DataType_Boolean;
		}
		else if([debugString hasPrefix:@"Number:"])
		{
			index = [[debugArgs objectForKey:@"index"] intValue];
			name = [debugArgs objectForKey:@"name"];
			type = NoPL_DataType_Number;
		}
		else if([debugString hasPrefix:@"String:"])
		{
			index = [[debugArgs objectForKey:@"index"] intValue];
			name = [debugArgs objectForKey:@"name"];
			type = NoPL_DataType_String;
		}
		
		if(index >= 0 || name)
			[scriptVarData addVariable:type name:name index:index];
	}
}

-(void)compileScriptFromTimer
{
	recompileTimer = NULL;
	
	[self compileScript];
}

#pragma mark - Notifications

-(void)scriptFileWasAdded:(NSNotification*)note
{
	//save the old file
	[self saveCurrentScript];
	
	//open the new file
	NSString* path = [[note userInfo] objectForKey:kFileBroswer_SelectedPathKey];
	NSError* err;
	NSString* pathContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
	if(!err)
	{
		//set up the script in the editor
		currentFilePath = path;
		[scriptView setString:pathContents];
	}
	
	[self compileScript];
}

-(void)scriptDidOutput:(NSNotification*)note
{
	NSString* appendedStr = [[note userInfo] objectForKey:kNoPL_ConsoleOutputKey];
	
	NSString* debugPrefix = @"NoPL Debug: ";
	if([appendedStr hasPrefix:debugPrefix])
	{
		appendedStr = [appendedStr substringFromIndex:[debugPrefix length]];
		[self handleDebugOutput:appendedStr];
	}
	else
	{
		[self appendToConsole:appendedStr];
	}
}

#pragma mark - IB functions

- (IBAction)buildRunClicked:(id)sender
{
	//compile the script and get the path
	NSString* outputPath = [self compileScript];
	if(outputPath)
	{
		//save if the script compiled successfully
		[self saveCurrentScript];
	}
	else
	{
		[self appendToConsole:@"Script Was not run because it did not compile successfully."];
		return;
	}
	
	//reset script line
	scriptExecutionLine = -1;
	
	//set up the debug handle for debugging the script
	NSData* compiledData = [NSData dataWithContentsOfFile:outputPath];
	debugHandle = createNoPL_DebugHandle([compiledData bytes], (unsigned int)[compiledData length], &callbacks);
	
	//debug the script
	[self stepScript:YES];
}

- (IBAction)buildClicked:(id)sender
{
	//compile the script, save if compile was successful
	if([self compileScript])
		[self saveCurrentScript];
}

- (IBAction)continueClicked:(id)sender
{
	[self stepScript:YES];
}

- (IBAction)stepClicked:(id)sender
{
	int stepStartLine = scriptExecutionLine;
	while(debugHandle && stepStartLine == scriptExecutionLine)
		[self stepScript:NO];
	
	//say where the script execution is if it's still not finished
	if(debugState)
	{
		[self appendToConsole:[NSString stringWithFormat:@"Stepped to line %d", scriptExecutionLine]];
	}
}

- (IBAction)stopClicked:(id)sender
{
	[self endExecution];
}

- (IBAction)debugCommandEntered:(id)sender
{
	if(sender != debugInputView)
		return;
	
	//get the string that the user entered
	NSString* command = [debugInputView stringValue];
	if([command isEqualToString:@""])
		return;
	
	//remove the command from the input view
	[debugInputView setStringValue:@""];
	
	//append the command to the console
	[self appendToConsole:command];
	
	//run the command
	[self processDebugCommand:command];
	
	//put the command in the history
	[commandHistory addObject:command];
	
	//cap the size of the history at the max
	while([commandHistory count] > kScriptController_MaxCommandHistory)
		[commandHistory removeObjectAtIndex:0];
	
	//set the history index
	commandHistoryIndex = [commandHistory count];
}

-(IBAction)saveSelectedFromMenu:(id)sender
{
	[self saveCurrentScript];
}

-(IBAction)outputCompiledSpreadsheet:(id)sender
{
	//set up objects for compilation
	NoPL_CompileContext ctx = newNoPL_CompileContext();
	NoPL_CompileOptions options = NoPL_CompileOptions();
	options.createTokenRanges = 1;
	options.debugSymbols = 1;
	options.optimizeForRuntime = 0;
	
	//compile the script
	compileContextWithString([[scriptView string] UTF8String], &options, &ctx);
	
	//check if the compile succeded
	NSMutableString* outputBuffer = [NSMutableString stringWithCapacity:1000];
	if(!ctx.errDescriptions)
	{
		//build a csv file with anything that might be important
		[outputBuffer appendString:@"Byte Index, Operator, uByte, uShort, short, float, bool, UTF8\n"];
		for(int i = 0; i < ctx.dataLength; i++)
		{
			void* scriptData = &(ctx.compiledData[i]);
			NoPL_Instruction* inst = (NoPL_Instruction*)scriptData;
			unsigned char* uByte = (unsigned char*)scriptData;
			unsigned short* uShort = (unsigned short*)scriptData;
			short* _short = (short*)scriptData;
			float* _float = (float*)scriptData;
			NSString* boolStr = (*((int*)scriptData)) ? @"true" : @"false";
			char charString[2];
			charString[0] = (*uByte < 128) ? *uByte : '\0';
			charString[1] = '\0';
			[outputBuffer appendFormat:@"%d,%@,%hhu,%hu,%hd,%f,%@,%s\n",
										i,
										noplInstructionToString(*inst),
										*uByte,
										*uShort,
										*_short,
										*_float,
										boolStr,
										charString];
		}
		
		//save to output file
		NSString* outputPath = [[currentFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"csv"];
		[outputBuffer writeToFile:outputPath atomically:NO encoding:NSASCIIStringEncoding error:NULL];
		[self appendToConsole:[NSString stringWithFormat:@"Spreadsheet was saved to '%@'", [outputPath lastPathComponent]]];
	}
	else
	{
		//show the compile error in the console
		[self appendToConsole:[NSString stringWithUTF8String:ctx.errDescriptions]];
	}
	
	freeNoPL_CompileContext(&ctx);
}

-(void)textDidChange:(NSNotification *)notification
{
	//can't edit the script while it's running, stop the execution if we're changing it
	if(debugState != DebuggerState_NotRunning)
	{
		[self setDebugState:DebuggerState_NotRunning];
		[self appendToConsole:@"Debugging was stopped due to changes to script."];
	}
	else
	{
		if(recompileTimer)
			[recompileTimer invalidate];
		recompileTimer = [NSTimer scheduledTimerWithTimeInterval:kScriptController_CompileDelay target:self selector:@selector(compileScriptFromTimer) userInfo:NULL repeats:NO];
	}
}

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
	//we only care about the debug input here
	if(control == debugInputView)
	{
		//did the user press the up or down arrow key?
		if(commandSelector == @selector(moveUp:))
		{
			//adjust the debug input to show the previous entry
			if(commandHistoryIndex > 0)
			{
				commandHistoryIndex--;
				[self updateDebugInputToCurrentIndex];
			}
		}
		else if(commandSelector == @selector(moveDown:))
		{
			//adjust the debug input to show the next entry
			if(commandHistoryIndex < [commandHistory count])
			{
				commandHistoryIndex++;
				[self updateDebugInputToCurrentIndex];
			}
		}
	}
	return NO;
}

@end
