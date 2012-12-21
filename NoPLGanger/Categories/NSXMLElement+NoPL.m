//
//  NSXMLElement+NoPL.m
//  NoPLGanger
//
//  Created by Brad Bambara on 12/20/12.
//  Copyright (c) 2012 Brad Bambara. All rights reserved.
//

#import "NSXMLElement+NoPL.h"

@implementation NSXMLElement (NoPL)

-(NoPL_FunctionValue)callFunction:(void*)calledOnObject functionName:(NSString*)name args:(const NoPL_FunctionValue*)args argCount:(unsigned int)count
{
	//only respond if the called object is self
	if(count == 0 && (!calledOnObject || calledOnObject == (__bridge void *)(self)))
	{
		NSXMLNode* valueNode = [self attributeForName:name];
		if(valueNode)
		{
			NoPL_FunctionValue returnVal;
			const char* utf8Str = [valueNode.stringValue UTF8String];
			NoPL_assignString(utf8Str, returnVal);
			return returnVal;
		}
	}
	return [super callFunction:calledOnObject functionName:name args:args argCount:count];
}

-(NoPL_FunctionValue)getSubscript:(void*)calledOnObject index:(NoPL_FunctionValue)index
{
	return [super getSubscript:calledOnObject index:index];
}

@end
