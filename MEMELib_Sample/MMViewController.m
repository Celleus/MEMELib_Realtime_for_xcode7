//
//  MMViewController.m
//  
//
//  Created by JINS MEME on 8/11/14.
//  Copyright (c) 2014 JIN. All rights reserved.
//

#import "MMViewController.h"
#import <MEMELib/MEMELib.h>

@interface MMViewController ()

@property (nonatomic, strong) NSMutableArray *peripheralsFound;

@end

@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set delegate instance
    [MEMELib sharedInstance].delegate = self;
    //observe BLE status
    [[MEMELib sharedInstance] addObserver: self forKeyPath: @"centralManagerEnabled" options: NSKeyValueObservingOptionNew context:nil];
    
    self.peripheralsFound = @[].mutableCopy;
    
    self.title      = @"JINS MEME Demo";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Scan" style:UIBarButtonItemStylePlain target: self action:@selector(scanButtonPressed:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString: @"centralManagerEnabled"]){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanButtonPressed:(id)sender {
    // Start Scanning
    MEMEStatus status = [[MEMELib sharedInstance] startScanningPeripherals];
    [self checkMEMEStatus: status];
}

#pragma mark
#pragma mark MEMELib Delegates

- (void) memePeripheralFound: (CBPeripheral *) peripheral withDeviceAddress:(NSString *)address
{
    [self.peripheralsFound addObject: peripheral];
    NSLog(@"peripheral found %@", [peripheral.identifier UUIDString]);
    [self.tableView reloadData];
}

- (void) memePeripheralConnected: (CBPeripheral *)peripheral
{
    NSLog(@"MEME Device Connected!");
    
    self.navigationItem.rightBarButtonItem.enabled         = NO;
    self.tableView.userInteractionEnabled = NO;
//    [self performSegueWithIdentifier:@"DataViewSegue" sender: self];
    
    self.dataViewCtl = [[MMDataViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.dataViewCtl];
    [self presentViewController:navigationController animated:YES completion:^{}];
    
    [[MEMELib sharedInstance] startDataReport];
}

- (void) memePeripheralDisconnected: (CBPeripheral *)peripheral
{
    self.navigationItem.rightBarButtonItem.enabled       = YES;
    self.tableView.userInteractionEnabled = YES;
    
    [self dismissViewControllerAnimated: YES completion: ^{
        self.dataViewCtl = nil;
        NSLog(@"MEME Device Disconnected");

    }];
}

- (void) memeRealTimeModeDataReceived: (MEMERealTimeData *) data
{
    if (self.dataViewCtl) [self.dataViewCtl memeRealTimeModeDataReceived: data];
}

- (void) memeAppAuthorized:(MEMEStatus)status
{
    [self checkMEMEStatus: status];
}

- (void) memeCommandResponse:(MEMEResponse)response
{
    switch (response.eventCode) {
        case 0x02:
            NSLog(@"start data report : result %d", response.commandResult);
            break;
        case 0x04:
            NSLog(@"stop data report : result %d", response.commandResult);
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark Peripheral List

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.peripheralsFound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DeviceListCellIdentifier"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"DeviceListCellIdentifier"];
    }
    
    CBPeripheral *peripheral = [self.peripheralsFound objectAtIndex: indexPath.row];
    cell.textLabel.text = [peripheral.identifier UUIDString];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = [self.peripheralsFound objectAtIndex: indexPath.row];
    // Connect JINS MEME
    MEMEStatus status = [[MEMELib sharedInstance] connectPeripheral: peripheral ];
    [self checkMEMEStatus: status];
    
    NSLog(@"Start connecting to MEME Device...");
}

//- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString: @"DataViewSegue"]){
//        UINavigationController *naviCtl = segue.destinationViewController;
//        self.dataViewCtl                = (MMDataViewController *)naviCtl.topViewController;
//    }
//}

#pragma mark UTILITY

- (void) checkMEMEStatus: (MEMEStatus) status
{
    if (status == MEME_ERROR_APP_AUTH){
        [[[UIAlertView alloc] initWithTitle: @"App Auth Failed" message: @"Invalid Application ID or Client Secret " delegate: nil cancelButtonTitle: nil otherButtonTitles: @"OK", nil] show];
    } else if (status == MEME_ERROR_SDK_AUTH){
        [[[UIAlertView alloc] initWithTitle: @"SDK Auth Failed" message: @"Invalid SDK. Please update to the latest SDK." delegate: nil cancelButtonTitle: nil otherButtonTitles: @"OK", nil] show];
    } else if (status == MEME_OK){
        NSLog(@"Status: MEME_OK");
    }
}



@end
