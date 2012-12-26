//
//  NoPLTextField.m
//  NoPLGanger
//
//  Created by Brad Bambara on 12/22/12.
//  Copyright (c) 2012 Brad Bambara. All rights reserved.
//

#import "NoPLTextField.h"

@implementation NoPLTextField

- (void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"KEY DOWN");
	
	[super keyDown:theEvent];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNoPLTextField_KeyDownNoteName
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:theEvent forKey:kNoPLTextField_KeyDownEventKey]];
}

@end
