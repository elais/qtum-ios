//
//  FirstAuthViewController.m
//  qtum wallet
//
//  Created by Никита Федоренко on 21.02.17.
//  Copyright © 2017 Designsters. All rights reserved.
//

#import "FirstAuthViewController.h"

@interface FirstAuthViewController ()

@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;

- (IBAction)createNewButtonWasPressed:(id)sender;

@end

@implementation FirstAuthViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.restoreButton setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.3f]];
    [self.createButton setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.3f]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createNewButtonWasPressed:(id)sender{
    if ([self.delegate respondsToSelector:@selector(createNewButtonPressed)]) {
        [self.delegate createNewButtonPressed];
    }
}

- (IBAction)restoreButtonWasPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(restoreButtonPressed)]) {
        [self.delegate restoreButtonPressed];
    }
}



@end
