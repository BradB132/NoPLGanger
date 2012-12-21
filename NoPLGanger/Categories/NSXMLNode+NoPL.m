//
//  NSXMLNode+NoPL.m
//  NoPLGanger
//
//  Created by Brad Bambara on 12/20/12.
//  Copyright (c) 2012 Brad Bambara. All rights reserved.
//

#import "NSXMLNode+NoPL.h"
#import "DataManager.h"

@implementation NSXMLNode (NoPL)

-(NoPL_FunctionValue)callFunction:(void*)calledOnObject functionName:(NSString*)name args:(const NoPL_FunctionValue*)args argCount:(unsigned int)count
{
	if(count > 0)
		return NoPL_FunctionValue();
	
	//only respond if the called object is self
	if(!calledOnObject || calledOnObject == (__bridge void *)(self))
	{
		if([name isEqualToString:@"size"] || [name isEqualToString:@"count"] || [name isEqualToString:@"length"])
		{
			NoPL_FunctionValue val;
			val.numberValue = [[self children] count];
			val.type = NoPL_DataType_Number;
			return val;
		}
	}
	return NoPL_FunctionValue();
}

-(NoPL_FunctionValue)getSubscript:(void*)calledOnObject index:(NoPL_FunctionValue)index
{
	//only respond if the called object is self
	if(!calledOnObject || calledOnObject == (__bridge void *)(self))
	{
		if(index.type == NoPL_DataType_Number)
		{
			//attempt to retreive the value and convert to function result
			int arrIndex = (int)index.numberValue;
			if(arrIndex < [[self children] count] && arrIndex >= 0)
			{
				id val = [[self children] objectAtIndex:arrIndex];
				if(val)
					return [DataManager objectToFunctionValue:val];
			}
		}
	}
	return NoPL_FunctionValue();
}

@end
