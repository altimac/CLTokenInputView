//
//  MKSToken.h
//  CLTokenInputView
//
//  Created by Aurélien Hugelé on 23/06/2016.
//  Copyright © 2016 Cluster Labs, Inc. All rights reserved.
//

#import "CLToken.h"

@interface MKSToken : CLToken

@property(assign, nonatomic) NSUInteger locationInText; // helps sorting, not really usefull except for internals

@end
