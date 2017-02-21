//
//  CreatePinViewController.m
//  qtum wallet
//
//  Created by Никита Федоренко on 30.12.16.
//  Copyright © 2016 Designsters. All rights reserved.
//

#import "CreatePinViewController.h"
#import "CustomTextField.h"
#import "StartNavigationCoordinator.h"

@interface CreatePinViewController () <CAAnimationDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gradientViewBottomOffset;

@end

@implementation CreatePinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.firstSymbolTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.firstSymbolTextField becomeFirstResponder];
}

#pragma mark - Keyboard

-(void)keyboardWillShow:(NSNotification *)sender{
    CGRect end = [[sender userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.gradientViewBottomOffset.constant = end.size.height;
    [self.view layoutIfNeeded];
}

-(void)keyboardWillHide:(NSNotification *)sender{
    self.gradientViewBottomOffset.constant = 0;
    [self.view layoutIfNeeded];
}

#pragma mark - Configuration

#pragma mark - Privat Methods


#pragma mark - Actions


- (IBAction)actionEnterPin:(id)sender {

}
- (IBAction)confirmButtomPressed:(id)sender {
    NSString* pin = [NSString stringWithFormat:@"%@%@%@%@",self.firstSymbolTextField.text,self.secondSymbolTextField.text,self.thirdSymbolTextField.text,self.fourthSymbolTextField.text];
    if (pin.length == 4) {
        if ([self.delegate performSelector:@selector(didCreatedWalletName:)]) {
            [self.delegate didCreatedWalletName:pin];
        }
    } else {
        [self accessPinDenied];
    }
}

- (IBAction)actionCancel:(id)sender {
    NSString* pin = [NSString stringWithFormat:@"%@%@%@%@",self.firstSymbolTextField.text,self.secondSymbolTextField.text,self.thirdSymbolTextField.text,self.fourthSymbolTextField.text];
    if (pin.length == 4) {
        if ([self.delegate performSelector:@selector(didCreatedWalletName:)]) {
            [self.delegate didCreatedWalletName:pin];
        }
    } else {
        [self accessPinDenied];
    }
//    if ([self.delegate performSelector:@selector(cancelCreateWallet)]) {
//        [self.delegate cancelCreateWallet];
//    }
}


@end
