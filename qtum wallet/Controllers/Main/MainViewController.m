//
//  MainViewController.m
//  qtum wallet
//
//  Created by Sharaev Vladimir on 18.11.16.
//  Copyright © 2016 Designsters. All rights reserved.
//

#import "MainViewController.h"
#import "HistoryTableViewCell.h"
#import "BlockchainInfoManager.h"
#import "NewPaymentViewController.h"
#import "RecieveViewController.h"
#import "HistoryElement.h"
#import "QRCodeViewController.h"
#import "ApplicationCoordinator.h"
#import "GradientViewWithAnimation.h"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, QRCodeViewControllerDelegate>

@property (nonatomic) NSDictionary *dictionaryForNewPayment;

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GradientViewWithAnimation *topBoardView;
@property (weak, nonatomic) IBOutlet UIView *quickInfoBoard;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBoardQuckBoardOffset;
@property (weak, nonatomic) IBOutlet UIView *customNavigationBar;
@property (weak, nonatomic) IBOutlet UIView *topSubstrateView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
@property (weak, nonatomic) IBOutlet UIView *shortInfoView;


@property (nonatomic) BOOL balanceLoaded;
@property (nonatomic) BOOL historyLoaded;
@property (nonatomic) NSArray *historyArray;

- (IBAction)refreshButtonWasPressed:(id)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat offset = self.topBoardView.frame.size.height + self.quickInfoBoard.frame.size.height;
    self.tableView.contentInset =
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(offset, 0, 0, 0);

    self.balanceLabel.text = @"0";
    self.historyLoaded = YES;
    
    [self configRefreshControl];
    [self configAdressLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.topBoardView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // get all dataForScreen
    [self refreshButtonWasPressed:nil];
}

#pragma mark - Configuration

-(void)configRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshButtonWasPressed:) forControlEvents:UIControlEventValueChanged];
}

-(void)configAdressLabel{
    self.adressLabel.text = [WalletManager sharedInstance].getCurrentWallet.getRandomKey.address.string;
}

- (IBAction)refreshButtonWasPressed:(id)sender
{
    [self.refreshControl endRefreshing];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getBalance];
        [self getHistory];
    });
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryTableViewCell"];
    if (!cell) {
        cell = [[HistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistoryTableViewCell"];
    }
    
    HistoryElement *element = self.historyArray[indexPath.row];
    cell.historyElement = element;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.historyArray.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static CGFloat previousOffset;
    NSInteger yOffset = scrollView.contentOffset.y < scrollView.contentInset.top * -1 ? scrollView.contentInset.top * -1 : scrollView.contentOffset.y;
    
    CGRect rect1 = self.topBoardView.frame;
    CGRect rect2 = self.quickInfoBoard.frame;
    CGRect rect3 = self.topSubstrateView.frame;


    rect1.origin.y += previousOffset - yOffset;
    
//    //stop moving quic info bar
//    if ( yOffset <= (self.customNavigationBar.frame.size.height + rect2.size.height) * -1) {
//        rect2.origin.y += previousOffset - yOffset;
//    }else {
//        NSLog(@"%ld",(long)yOffset);
//    }
    rect2.origin.y += previousOffset - yOffset;
    rect3.origin.y += previousOffset - yOffset;
    
    self.topBoardView.frame = rect1;
    self.quickInfoBoard.frame = rect2;
    self.topSubstrateView.frame = rect3;
    
    previousOffset = yOffset;
    
    NSLog(@"%ld",(long)yOffset);
    
    [self setUpNavigationBar];
}

-(void)setUpNavigationBar{
    BOOL flag = self.quickInfoBoard.frame.origin.y <= self.customNavigationBar.frame.size.height;

    self.customNavigationBar.backgroundColor = flag ? [UIColor colorWithRed:54/255. green:85/255. blue:200/255. alpha:1] : [UIColor clearColor];
//    self.shortInfoView.hidden = !flag;
}

#pragma mark - Methods

- (void)getBalance
{
    self.balanceLoaded = NO;
    
    __weak typeof(self) weakSelf = self;
    [BlockchainInfoManager getBalanceForAllAddresesWithSuccessHandler:^(double responseObject) {
        weakSelf.balanceLabel.text = [NSString stringWithFormat:@"%lf", responseObject];
        weakSelf.balanceLoaded = YES;
        
        if (weakSelf.balanceLoaded && weakSelf.historyLoaded) {
            [SVProgressHUD dismiss];
        }
    } andFailureHandler:^(NSError *error, NSString *message) {
        weakSelf.balanceLoaded = YES;
        if (weakSelf.balanceLoaded && weakSelf.historyLoaded) {
            [SVProgressHUD showErrorWithStatus:@"Some error"];
        }
    }];
}

- (void)getHistory
{
    self.historyLoaded = NO;
    
    __weak typeof(self) weakSelf = self;
    [BlockchainInfoManager getHistoryForAllAddresesWithSuccessHandler:^(NSArray *responseObject) {
        weakSelf.historyLoaded = YES;
        weakSelf.historyArray = responseObject;
        [weakSelf.tableView reloadData];
        
        if (weakSelf.balanceLoaded && weakSelf.historyLoaded) {
            [SVProgressHUD dismiss];
        }
        NSLog(@"%@", responseObject);
    } andFailureHandler:^(NSError *error, NSString *message) {
        weakSelf.historyLoaded = YES;
        if (weakSelf.balanceLoaded && weakSelf.historyLoaded) {
            [SVProgressHUD showErrorWithStatus:@"Some error"];
        }
    }];
}

#pragma mark - QRCodeViewControllerDelegate

- (void)qrCodeScanned:(NSDictionary *)dictionary
{
    self.dictionaryForNewPayment = dictionary;
}

#pragma mark - Actions
- (IBAction)actionRecive:(id)sender {
    [self performSegueWithIdentifier:@"recive" sender:self];

}

- (void)showNextVC
{
    [self performSegueWithIdentifier:@"FromMainToNewPayment" sender:self];
}

- (IBAction)actionShowMenu:(id)sender {
//    [[ApplicationCoordinator sharedInstance] showMenu];
}

#pragma merk - Seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueID = segue.identifier;
    
    if ([segueID isEqualToString:@"FromMainToNewPayment"]) {
        NewPaymentViewController *vc = (NewPaymentViewController *)segue.destinationViewController;
        
        vc.currentBalance = self.balanceLabel.text;
        vc.dictionary = self.dictionaryForNewPayment;
        self.dictionaryForNewPayment = nil;
    }
    
    if ([segueID isEqualToString:@"MaintToRecieve"]) {
        RecieveViewController *vc = (RecieveViewController *)segue.destinationViewController;
        
        vc.balance = self.balanceLabel.text;
    }
    
    if ([segueID isEqualToString:@"qrCode"]) {
        QRCodeViewController *vc = (QRCodeViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
}
@end
