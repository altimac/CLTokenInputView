//
//  MKSTokenView.m
//  CLTokenInputView
//
//  Created by Aurélien Hugelé on 21/06/2016.
//  Copyright © 2016 Cluster Labs, Inc. All rights reserved.
//

#import "MKSTokenView.h"
#import "CLToken.h"

@implementation MKSTokenView

- (id)initWithToken:(MKSToken *)token font:(nullable UIFont *)font
{
    self = [super initWithToken:(CLToken*)token font:font];
    if(self) {
        _token = token;
    }
    
    return self;
}

-(void)setHideUnselectedComma:(BOOL)hideUnselectedComma
{
    [super setHideUnselectedComma:YES]; // always hide unselected commas
}

@end
