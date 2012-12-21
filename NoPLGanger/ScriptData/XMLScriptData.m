//
//  XMLScriptData.m
//  NoPLGanger
//
//  Created by Brad Bambara on 10/18/12.
//  Copyright (c) 2012 Brad Bambara. All rights reserved.
//

#import "XMLScriptData.h"
#import "NSXMLNode+NoPL.h"
#import "DataManager.h"

@implementation XMLScriptData

-(id)initWithPath:(NSString*)path
{
	if([[path pathExtension] compare:@"xml" options:NSCaseInsensitiveSearch] != NSOrderedSame)
		return nil;
	
	self = [super init];
	if(self)
	{
		originalPath = path;
		xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] options:NSXMLNodePreserveCDATA error:nil];
	}
	return self;
}

-(NoPL_FunctionValue)callFunction:(void*)calledOnObject functionName:(NSString*)name args:(const NoPL_FunctionValue*)args argCount:(unsigned int)count
{
	//forward this call
	if(!calledOnObject || calledOnObject == (__bridge void *)([xmlDoc rootElement]))
	{
		if([name isEqualToString:[[xmlDoc rootElement] name]])
		{
			return [DataManager objectToFunctionValue:[xmlDoc rootElement]];
		}
	}
	return NoPL_FunctionValue();
}

-(NoPL_FunctionValue)getSubscript:(void*)calledOnObject index:(NoPL_FunctionValue)index
{
	//forward this call
	if(!calledOnObject || calledOnObject == (__bridge void *)([xmlDoc rootElement]))
		return [[xmlDoc rootElement] getSubscript:calledOnObject index:index];
	return NoPL_FunctionValue();
}

@end
