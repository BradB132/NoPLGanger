//
//  NSXMLElement+NoPL.h
//  NoPLGanger
//
//  Created by Brad Bambara on 12/20/12.
//  Copyright (c) 2012 Brad Bambara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSXMLNode+NoPL.h"

@interface NSXMLElement (NoPL)

-(NoPL_FunctionValue)callFunction:(void*)calledOnObject functionName:(NSString*)name args:(const NoPL_FunctionValue*)args argCount:(unsigned int)count;
-(NoPL_FunctionValue)getSubscript:(void*)calledOnObject index:(NoPL_FunctionValue)index;

@end
