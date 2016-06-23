//
//  CLTokenInputViewController.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenInputViewController.h"

#import "MKSToken.h"
#import "MKSTokenView.h"

@interface CLTokenInputViewController ()

@property (strong, nonatomic) NSArray *names;
@property (strong, nonatomic) NSArray *filteredNames;

@property (strong, nonatomic) NSMutableArray *selectedNames;

@end

@implementation CLTokenInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Token Input Test";
        self.names = @[@"San Francisco",
                       @"Pizza",
                       @"Vegan",
                       @"Burger",
                       @"Best Burger", @"Paris", @"friend", @"drink", @"New York", @"hipster", @"broadway", @"show", @"france", @"hiking", @"competition", @"tel aviv", @"beach", @"animation"];
        self.filteredNames = [self.names copy];
        self.selectedNames = [NSMutableArray arrayWithCapacity:self.names.count];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infoButton addTarget:self action:@selector(onFieldInfoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.secondTokenInputView.placeholderText = @"Marks tests here...";
    self.secondTokenInputView.fieldFont = [UIFont fontWithName:@"Georgia" size:17];
    //self.secondTokenInputView.fieldName = NSLocalizedString(@", \" \", return:", nil);
    self.secondTokenInputView.tokenizationCharacters = [NSSet setWithObjects:@",",@" ", nil];
    self.secondTokenInputView.drawBottomBorder = YES;
    self.secondTokenInputView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLTokenInputViewDelegate

-(BOOL)tokenInputView:(CLTokenInputView *)view shouldAllowTokenizationCharacterReplacement:(NSString *)tokenizationCharacter inRange:(NSRange)range
{
    return YES;
}

- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text
{
    // AH, I don't want tableview
    self.tableView.hidden = YES;
    return;
    
//    if ([text isEqualToString:@""]){
//        //self.filteredNames = nil;
//        self.tableView.hidden = YES;
//    } else {
//        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", text];
//        //self.filteredNames = [self.names filteredArrayUsingPredicate:predicate];
//        self.tableView.hidden = NO;
//    }
//    [self.tableView reloadData];
}

-(void)tokenInputView:(CLTokenInputView *)view willAddTokenView:(CLTokenView *)tokenView forToken:(CLToken *)token
{
    if([(MKSToken*)token isRecognized]) {
        // for the moment put some random/crazy colors on the tokenView
        tokenView.selectedTintColor = [UIColor lightGrayColor];
        tokenView.selectedBackgroundColor = [UIColor darkGrayColor];
        tokenView.tintColor = [UIColor whiteColor];
        tokenView.backgroundColor = [UIColor orangeColor];
    }
    else {
        tokenView.selectedTintColor = [UIColor darkTextColor];
        tokenView.selectedBackgroundColor = [UIColor lightGrayColor];
        tokenView.tintColor = [UIColor darkTextColor];
        tokenView.backgroundColor = [UIColor clearColor];
    }
}

- (void)tokenInputView:(CLTokenInputView *)view didAddToken:(CLToken *)token
{
    NSString *name = token.displayText;
    [self.selectedNames addObject:name];
}

- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token
{
    NSString *name = token.displayText;
    [self.selectedNames removeObject:name];
}

- (CLToken *)tokenInputView:(CLTokenInputView *)view tokenForText:(NSString *)text
{
    __block MKSToken *token = nil;
    [self.filteredNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = obj;
        if([name localizedCaseInsensitiveCompare:text] == NSOrderedSame) {
            token = [[MKSToken alloc] initWithDisplayText:name context:nil];
            *stop = YES;
        }
    }];
     
    return (CLToken*)token;
}

- (NSArray <CLToken*> *)tokenInputView:(CLTokenInputView *)view tokensForText:(NSString *)text
{
    NSMutableSet <MKSToken*> *tokens = [NSMutableSet set];
    BOOL shouldSkipOtherTokenizationCharacters = NO;
    // FIXME: there is a bug with multiple tokenizationCharacters as we may add some token in wrong sequence. But this should be rare
    
    for(NSString *separator in view.tokenizationCharacters) {
        
        if(shouldSkipOtherTokenizationCharacters)  break;
        
        NSString *processedText = [text copy];
       // NSRange lastFoundLHSToken = NSMakeRange(0, 0);
        NSRange separatorRange = NSMakeRange(0, 0);
        
        MKSToken *lhsToken;
        MKSToken *rhsToken;
        
        do {
            lhsToken = nil;
            rhsToken = nil;
            
            separatorRange = [processedText rangeOfString:separator options:0 range:NSMakeRange(separatorRange.location+separatorRange.length, processedText.length-(separatorRange.location+separatorRange.length))];
 
            if(separatorRange.location == NSNotFound) {
                // a sentence of one word
                if([self _isEntireSentenceAToken:processedText]) {
                    lhsToken = [[MKSToken alloc] initWithDisplayText:processedText context:nil];
                    lhsToken.recognized = YES;
                    [tokens addObject:lhsToken];
                    
                    if([processedText isEqualToString:text]) {
                        shouldSkipOtherTokenizationCharacters = YES; // we want to avoid testing other tokenizationCharacters since "best burger" will give "best burger" + "burger" tokens.
                    }
                }
            }
            else {
                // a sentence with several words
                NSString *lhs = [processedText substringWithRange:NSMakeRange(0, separatorRange.location)];
                NSString *rhs = [processedText substringWithRange:NSMakeRange(separatorRange.location+separatorRange.length, processedText.length-(separatorRange.location+separatorRange.length))];

                if([self _isEntireSentenceAToken:lhs]) {
                    lhsToken = [[MKSToken alloc] initWithDisplayText:lhs context:nil];
                    lhsToken.recognized = YES;
                    [tokens addObject:lhsToken];
                    
                    // remove lhs from processedText
                    processedText = [rhs copy];
                    separatorRange = NSMakeRange(0, 0); // reset
                }
                
                if([self _isEntireSentenceAToken:rhs]) {
                rhsToken = [[MKSToken alloc] initWithDisplayText:rhs context:nil];
                    rhsToken.recognized = YES;
                    [tokens addObject:rhsToken];
                    
                    // remove rhs from processedText
                    processedText = [processedText stringByReplacingCharactersInRange:NSMakeRange(separatorRange.location, processedText.length-(separatorRange.location)) withString:@""];
                    separatorRange = NSMakeRange(0, 0); // reset
                }
            }
        }
        while(separatorRange.location != NSNotFound || (lhsToken != nil && rhsToken != nil));        
    }
    
    // tokens maybe in the wrong order, so reorder it and form non recognized tokens now
    NSMutableArray <MKSToken*> *orderedRecognizedTokens = [NSMutableArray array];
    
    if(tokens.count > 0) {
        for (MKSToken *token in tokens) {
            NSRange range = [text rangeOfString:token.displayText options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
            token.locationInText = range.location;
            NSAssert(range.location != NSNotFound, @"A *recognized* token can't be found in original text!?");
        }
        
        [orderedRecognizedTokens setArray:[[tokens allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(locationInText)) ascending:YES]]]];
    }
    else {
        // form one big unrecognized token
        MKSToken *allTextToken = [[MKSToken alloc] initWithDisplayText:text context:nil];
        allTextToken.recognized = NO;
        [orderedRecognizedTokens addObject:allTextToken];
    }
    
    return orderedRecognizedTokens;
}

-(BOOL)_isEntireSentenceAToken:(NSString *)sentence {
    __block BOOL isToken = NO;
    [self.filteredNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *token = obj;
        if([token compare:sentence options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch] == NSOrderedSame) {
            isToken = YES;
            *stop = YES;
        }
    }];

    return isToken;
}

- (void)tokenInputViewDidEndEditing:(CLTokenInputView *)view
{
    NSLog(@"token input view did end editing: %@", view);
    view.accessoryView = nil;
}

- (void)tokenInputViewDidBeginEditing:(CLTokenInputView *)view
{
    NSLog(@"token input view did begin editing: %@", view);
    //view.accessoryView = [self contactAddButton]; // AH: we can have an accessory view while editing, but I don't want it
//    [self.view removeConstraint:self.tableViewTopLayoutConstraint];
//    self.tableViewTopLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
//    [self.view addConstraint:self.tableViewTopLayoutConstraint];
//    [self.view layoutIfNeeded];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *name = self.filteredNames[indexPath.row];
    cell.textLabel.text = name;
    if ([self.selectedNames containsObject:name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *name = self.filteredNames[indexPath.row];
    CLToken *token = [[CLToken alloc] initWithDisplayText:name context:nil];
    if(self.secondTokenInputView.isEditing){
        [self.secondTokenInputView addToken:token];
    }
}


#pragma mark - Demo Button Actions


- (void)onFieldInfoButtonTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Field View Button"
                                                        message:@"This view is optional and can be a UIButton, etc."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (void)onAccessoryContactAddButtonTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Accessory View Button"
                                                        message:@"This view is optional and can be a UIButton, etc."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Demo Buttons
- (UIButton *)contactAddButton
{
    UIButton *contactAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [contactAddButton addTarget:self action:@selector(onAccessoryContactAddButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return contactAddButton;
}

@end
