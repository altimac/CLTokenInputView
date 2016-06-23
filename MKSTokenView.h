//
//  MKSTokenView.h
//  CLTokenInputView
//
//  Created by Aurélien Hugelé on 21/06/2016.
//  Copyright © 2016 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenView.h"

@class MKSToken;

NS_ASSUME_NONNULL_BEGIN

@interface MKSTokenView : CLTokenView

@property(strong, nonatomic, nonnull) MKSToken *token; // because superclass does not keep a reference to the token!

- (id)initWithToken:(MKSToken *)token font:(nullable UIFont *)font;

-(void)setHideUnselectedComma:(BOOL)hideUnselectedComma;

@end

NS_ASSUME_NONNULL_END
