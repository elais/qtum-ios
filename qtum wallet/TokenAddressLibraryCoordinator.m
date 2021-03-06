//
//  TokenAddressLibraryCoordinator.m
//  qtum wallet
//
//  Created by Vladimir Lebedevich on 03.08.17.
//  Copyright © 2017 QTUM. All rights reserved.
//

#import "TokenAddressLibraryCoordinator.h"
#import "TokenAddressLibraryOutput.h"
#import "AddressTransferPopupViewController.h"
#import "TransactionManager.h"
#import "ErrorPopUpViewController.h"

@interface TokenAddressLibraryCoordinator () <TokenAddressLibraryOutputDelegate, PopUpWithTwoButtonsViewControllerDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, weak) NSObject <TokenAddressLibraryOutput> *addressOutput;
@property (nonatomic, copy) NSDictionary <NSString*, NSDictionary<NSString*, NSString*>*> *addressBalanceHashTable;

@end

@implementation TokenAddressLibraryCoordinator

-(instancetype)initWithNavigationViewController:(UINavigationController*)navigationController {
    
    self = [super init];
    if (self) {
        
        _navigationController = navigationController;
    }
    return self;
}

-(void)start {
    
    NSObject <TokenAddressLibraryOutput> *output = [[ControllersFactory sharedInstance] createTokenAddressControllOutput];
    output.delegate = self;
    output.addressesValueHashTable = self.token.addressBalanceDivByDecimalDictionary;
    output.symbol = self.token.symbol;
    self.addressBalanceHashTable = self.token.addressBalanceDivByDecimalDictionary;
    self.addressOutput = output;
    [self.navigationController pushViewController:[output toPresent] animated:YES];
}

-(void)makeTransferFromAddress:(NSString*)from toAddress:(NSString*) to withAmount:(NSString* )amount {
        
    SendInfoItem *item = [[SendInfoItem alloc] initWithQtumAddress:to tokenAddress:self.token.contractAddress amountString:amount fromQtumAddress:from];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate coordinatorLibraryDidEnd:self withQrCodeItem:item];
}

#pragma mark - Popup

- (void)showLoaderPopUp {
    [[PopUpsManager sharedInstance] showLoaderPopUp];
}

- (void)showCompletedPopUp {
    [[PopUpsManager sharedInstance] showInformationPopUp:self withContent:[PopUpContentGenerator contentForSend] presenter:nil completion:nil];
}

- (void)showErrorPopUp:(NSString *)message {
    
    PopUpContent *content = [PopUpContentGenerator contentForOupsPopUp];
    if (message) {
        content.messageString = message;
        content.titleString = NSLocalizedString(@"Failed", nil);
    }
    
    ErrorPopUpViewController *popUp = [[PopUpsManager sharedInstance] showErrorPopUp:self withContent:content presenter:nil completion:nil];
    [popUp setOnlyCancelButton];
}

- (void)hideLoaderPopUp {
    [[PopUpsManager sharedInstance] dismissLoader];
}

- (void)showStatusOfPayment:(TransactionManagerErrorType)errorType {
    
    switch (errorType) {
        case TransactionManagerErrorTypeNone:
            [self showCompletedPopUp];
            break;
        case TransactionManagerErrorTypeNoInternetConnection:
            break;
        case TransactionManagerErrorTypeNotEnoughMoney:
            [self showErrorPopUp:NSLocalizedString(@"You have insufficient funds for this transaction", nil)];
            break;
        case TransactionManagerErrorTypeInvalidAddress:
            [self showErrorPopUp:NSLocalizedString(@"Invalid QTUM Address", nil)];
            break;
        default:
            [self showErrorPopUp:nil];
            break;
    }
}


#pragma mark - TokenAddressLibraryOutputDelegate

-(void)didBackPress {
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate coordinatorLibraryDidEnd:self];
}

-(void)didPressCellAtIndexPath:(NSIndexPath*) indexPath withAddress:(NSString*)address {
    
    [[PopUpsManager sharedInstance] showAddressTransferPopupViewController:self presenter:nil toAddress:address withFromAddressVariants:self.addressBalanceHashTable completion:nil];
}

#pragma mark - PopUpWithTwoButtonsViewControllerDelegate

- (void)cancelButtonPressed:(PopUpViewController *)sender {
    [[PopUpsManager sharedInstance] hideCurrentPopUp:YES completion:nil];
}

- (void)okButtonPressed:(AddressTransferPopupViewController *)sender {
    
    if ([sender isKindOfClass:[AddressTransferPopupViewController class]]) {
        [[PopUpsManager sharedInstance] hideCurrentPopUp:YES completion:nil];
        [self makeTransferFromAddress:sender.fromAddress toAddress:sender.toAddress withAmount:[sender.amount stringByReplacingOccurrencesOfString:@"," withString:@"."]];
    } else {
        [[PopUpsManager sharedInstance] hideCurrentPopUp:YES completion:nil];
    }
}

@end
