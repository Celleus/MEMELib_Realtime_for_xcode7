//
//  MMDataViewController.h
//  MEMELib_Sample
//
//  Created by JINS MEME on 2015/03/30.
//  Copyright (c) 2015年 JINS MEME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MEMELib/MEMELib.h>

@class MMViewController;

@interface MMDataViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property ( nonatomic) IBOutlet UITableView        *dataTableView;

- (IBAction)startDataReportButtonPressed:(id)sender;
- (IBAction)stopDataReportButtonPressed:(id)sender;

- (void) memeRealTimeModeDataReceived: (MEMERealTimeData *)data;

@end
