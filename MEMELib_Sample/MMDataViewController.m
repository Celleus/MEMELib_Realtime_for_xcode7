//
//  MMDataViewController.m
//  MEMELib_Sample
//
//  Created by JINS MEME on 2015/03/30.
//  Copyright (c) 2015年 JINS MEME. All rights reserved.
//

#import "MMDataViewController.h"
#import <MEMELib/MEMELib.h>
#import "MMViewController.h"

@interface MMDataViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView    *indicatorView;

@property (strong, nonatomic) MEMERealTimeData *latestRealTimeData;

@end

@implementation MMDataViewController
{
    NSDateFormatter  *dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title      = @"Data Browser";
    
    // データの受信を示すランプ
    self.indicatorView                  = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 24, 24)];
    self.indicatorView.alpha            = 0.20;
    self.indicatorView.backgroundColor  = [UIColor whiteColor];
    self.indicatorView.layer.cornerRadius = self.indicatorView.frame.size.height * 0.5;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.indicatorView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Disconnect" style:UIBarButtonItemStylePlain target: self action:@selector(disconnectButtonPressed:)];
    
    // Date formatter for timestamp
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    self.dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height)];
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
    self.dataTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.dataTableView];
}

- (void) disconnectButtonPressed:(id) sender
{
    //disconnect JINS MEME
    MEMEStatus status =[[MEMELib sharedInstance] disconnectPeripheral];
    [self checkMEMEStatus: status];
}

- (void) checkMEMEStatus: (MEMEStatus) status
{
    if (status == MEME_ERROR_APP_AUTH){
        [[[UIAlertView alloc] initWithTitle: @"App Auth Failed" message: @"Invalid Application ID or Client Secret. " delegate: nil cancelButtonTitle: nil otherButtonTitles: @"OK", nil] show];
    } else if (status == MEME_ERROR_SDK_AUTH){
        [[[UIAlertView alloc] initWithTitle: @"SDK Auth Failed" message: @"Invalid SDK. Please update to the latest SDK." delegate: nil cancelButtonTitle: nil otherButtonTitles: @"OK", nil] show];
    } else if (status == MEME_OK){
        NSLog(@"Status: MEME_OK");
    }
}

- (void) memeRealTimeModeDataReceived: (MEMERealTimeData *)data
{
    self.latestRealTimeData = data;
    [self blinkIndicator];
    [self.dataTableView reloadData];
}

- (IBAction)startDataReportButtonPressed:(id)sender {
    //start data reporting
    MEMEStatus status =[[MEMELib sharedInstance] startDataReport];
    [self checkMEMEStatus: status];
}

- (IBAction)stopDataReportButtonPressed:(id)sender {
    //stop data reporting
    MEMEStatus status =[[MEMELib sharedInstance] stopDataReport];
    [self checkMEMEStatus: status];
}

- (void) blinkIndicator
{
    [UIView animateWithDuration: 0.05 animations:  ^{
        self.indicatorView.backgroundColor  = [UIColor redColor]; } completion:^(BOOL finished){
        [UIView animateWithDuration: 0.05 delay:0.25 options: 0 animations: ^{
            self.indicatorView.backgroundColor  = [UIColor whiteColor]; }  completion: nil];
    }];
}

#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DataCellIdentifier" forIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *label = @"";
    NSString *value = @"";
    
    MEMERealTimeData *data = self.latestRealTimeData;
    switch (indexPath.row) {
        case 0:
            label = @"Fit Status";
            value = FORMAT_INT(data.fitError);
            break;
            
        case 1:
            label = @"Walking";
            value = FORMAT_INT(data.isWalking);
            break;
            
        case 2:
            label = @"NoiseStatus";
            value = FORMAT_INT(data.noiseStatus);
            break;

        case 3:
            label = @"Power Left";
            value = FORMAT_INT(data.powerLeft);
            break;
            
        case 4:
            label = @"Eye Move Up";
            value = FORMAT_INT(data.eyeMoveUp);
            break;
            
        case 5:
            label = @"Eye Move Down";
            value = FORMAT_INT(data.eyeMoveDown);
            break;
            
        case 6:
            label = @"Eye Move Left";
            value = FORMAT_INT(data.eyeMoveLeft);
            break;
            
        case 7:
            label = @"Eye Move Right";
            value = FORMAT_INT(data.eyeMoveRight);
            break;
            
        case 8:
            label = @"Blink Streangth";
            value = FORMAT_INT(data.blinkStrength);
            break;
            
        case 9:
            label = @"Blink Speed";
            value = FORMAT_INT(data.blinkSpeed);
            break;
            
        case 10:
            label = @"Roll";
            value = FORMAT_FLOAT(data.roll);
            break;
            
        case 11:
            label = @"Pitch";
            value = FORMAT_FLOAT(data.pitch);
            break;
            
        case 12:
            label = @"Yaw";
            value = FORMAT_FLOAT(data.yaw);
            break;
            
        case 13:
            label = @"Acc X";
            value = FORMAT_FLOAT(data.accX);
            break;
            
        case 14:
            label = @"Acc Y";
            value = FORMAT_FLOAT(data.accY);
            break;
            
        case 15:
            label = @"Acc Z";
            value = FORMAT_FLOAT(data.accZ);
            break;
            
        default:
            break;
    }
    
    cell.textLabel.text = label;
    cell.detailTextLabel.text = value;
    
    return cell;
}


@end
