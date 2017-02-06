//
//  InvoiceListViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-14.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "InvoiceListViewController.h"

// Classes
#import "OrderManager.h"
#import "AppDelegate.h"

// Controllers
#import "InvoiceNewViewController.h"

@interface InvoiceListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *invoices;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation InvoiceListViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = [UIColor clearColor];
        naviTitle.textColor = [UIColor whiteColor];
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"地址管理";
        
        self.navigationItem.titleView = naviTitle;
        
        _invoiceType = @"manage";
    }
    
    return self;
}

#pragma makr UIView Functions

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 104) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    UIButton *editbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    editbutton.frame = CGRectMake(0, 0, 50, 44);
    [editbutton setTitle:@"编辑" forState:UIControlStateNormal];
    [editbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editbutton addTarget:self action:@selector(editTableView:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:editbutton];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    add.frame = CGRectMake(0, kScreenHeight - 104, kScreenWidth, 40);
    add.backgroundColor = [UIColor orangeColor];
    [add setTitle:@"新增发票" forState:UIControlStateNormal];
    [add addTarget:self action:@selector(newInvoice) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:add];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)newInvoice
{
    InvoiceNewViewController *invoice = [[InvoiceNewViewController alloc] init];

    UINavigationController *invoiceNC = [[UINavigationController alloc] initWithRootViewController:invoice];
    
    [self.navigationController presentViewController:invoiceNC animated:YES completion:nil];
}

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editTableView:(UIButton *)sender
{
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"编辑"]) {
        [sender setTitle:@"完成" forState:UIControlStateNormal];
        
        _tableView.editing = YES;
    } else {
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
        
        _tableView.editing = NO;
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = kAppDelegate;
    
    return appDelegate.user.invoices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (kDeviceOSVersion >= 7.0) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([_invoiceType isEqualToString:@"manage"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSArray *invoices = appDelegate.user.invoices;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 280, 16)];
    label.backgroundColor = kClearColor;
    label.font = kNormalFont;
    label.text = [[invoices objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    [cell.contentView addSubview:label];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if ([_invoiceType isEqualToString:@"pay"]) {
        NSString *invoice = [[appDelegate.user.invoices objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        [[OrderManager defaultManager] addInfo:invoice forKey:@"invoice"];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 44;
//}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 禁止滑动删除
    if (!_tableView.isEditing)
        return UITableViewCellEditingStyleNone;
    else {
        return UITableViewCellEditingStyleDelete;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate *appDelegate = kAppDelegate;
        
        NSMutableArray *temp = [NSMutableArray arrayWithArray:appDelegate.user.invoices];
        [temp removeObjectAtIndex:indexPath.row];
    
        appDelegate.user.invoices = [NSArray arrayWithArray:temp];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

@end
