//
//  TokenDetailInfoLightCell.h
//  qtum wallet
//
//  Created by Vladimir Lebedevich on 24.07.17.
//  Copyright © 2017 QTUM. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *tokenDetailInfoLightCellIdentifire = @"tokenDetailInfoLightCellIdentifire";

@interface TokenDetailInfoLightCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *availableBalance;
@property (weak, nonatomic) IBOutlet UILabel *symbol;
@property (weak, nonatomic) IBOutlet UILabel *tokenAddress;
@property (weak, nonatomic) IBOutlet UILabel *senderAddress;
@property (weak, nonatomic) IBOutlet UILabel *initialSupply;
@property (weak, nonatomic) IBOutlet UILabel *decimalUnits;
@property (strong, nonatomic) NSString *shortBalance;
@property (strong, nonatomic) NSString *shortTotalSupply;


-(void)updateWithScrollView:(UIScrollView*) scrollView;

@end
