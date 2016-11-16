//
//  ReceiveScreenViewController.m
//  OTScreenShareAccPackKit
//
//  Created by Xi Huang on 9/11/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "ReceiveScreenViewController.h"
#import "AppDelegate.h"
#import <OTScreenShareKit/OTScreenShareKit.h>

@interface ReceiveScreenViewController () <OTScreenShareDataSource>
@property (nonatomic) OTScreenSharer *screenSharer;
@end

@implementation ReceiveScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *previewBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Navigate" style:UIBarButtonItemStylePlain target:self action:@selector(navigateToOtherViews)];
    self.navigationItem.rightBarButtonItem = previewBarButtonItem;
    
    self.screenSharer = [[OTScreenSharer alloc] initWithDataSource:self];
    [self.screenSharer connectWithView:nil
                         handler:^(OTScreenShareSignal signal, NSError *error) {
                             
                             if (!error) {
                                 
                                 if (signal == OTScreenShareSignalSessionDidConnect) {
                                     self.screenSharer.publishAudio = NO;
                                     self.screenSharer.subscribeToAudio = NO;
                                 }
                                 else if (signal == OTScreenShareSignalSubscriberDidConnect) {
                                     
                                     [self.screenSharer.subscriberView removeFromSuperview];
                                     self.screenSharer.subscriberView.frame = self.view.bounds;
                                     [self.view insertSubview:self.screenSharer.subscriberView atIndex:0];
                                 }
                             }
                         }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.screenSharer disconnect];
}

- (void)navigateToOtherViews {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"MAKE FIT/FILL SCREEN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.screenSharer.isScreenSharing) {
            
            if (self.screenSharer.subscriberVideoContentMode == OTScreenShareVideoViewFit) {
                self.screenSharer.subscriberVideoContentMode = OTScreenShareVideoViewFill;
            }
            else {
                self.screenSharer.subscriberVideoContentMode = OTScreenShareVideoViewFit;
            }
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (OTAcceleratorSession *)sessionOfOTScreenSharer:(OTScreenSharer *)screenSharer {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
