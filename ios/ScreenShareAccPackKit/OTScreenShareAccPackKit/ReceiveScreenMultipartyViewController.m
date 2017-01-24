//
//  OTReceiveScreenMultipartyViewController.m
//  OTScreenShareKit
//
//  Created by javierfuchs on 1/23/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import "OTReceiveScreenMultipartyViewController.h"
#import "AppDelegate.h"
#import "OTMultiPartyScreenSharer.h"

@interface OTReceiveScreenMultipartyViewController () <OTMultiPartyScreenSharerDataSource>
@property (nonatomic, strong) UIBarButtonItem *subscribeButton;
@property (nonatomic) OTMultiPartyScreenSharer *screenSharer;
@end

@implementation OTReceiveScreenMultipartyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.subscribeButton;

    self.screenSharer = [[OTMultiPartyScreenSharer alloc] init];
    self.screenSharer.dataSource = self;
    
    [self.screenSharer connectWithView:nil
                               handler:^(OTCommunicationSignal signal, OTMultiPartyScreenShareRemote *subscriber, NSError *error) {
                                   if (!error) {
                                       
                                       if (signal == OTPublisherCreated) {
                                           subscriber.subscribeToAudio = NO;
                                       }
                                       else if (signal == OTSubscriberReady) {
                                           
                                           [subscriber.subscriberView removeFromSuperview];
                                           subscriber.subscriberView.frame = self.view.bounds;
                                           [self.view insertSubview:subscriber.subscriberView atIndex:0];
                                       }
                                   }
                               }];

}

- (UIBarButtonItem *)subscribeButton {
    if (!_subscribeButton) {
        _subscribeButton = [[UIBarButtonItem alloc] initWithTitle:([self.screenSharer isPublishOnly] ? @"Publish On" : @"Publish Off") style:UIBarButtonItemStylePlain target:self action:@selector(changePublishOnly)];
    }
    return _subscribeButton;
}

- (void)changePublishOnly {
    self.screenSharer.publishOnly = ![self.screenSharer isPublishOnly];
    self.subscribeButton.title = self.screenSharer.isPublishOnly ? @"Publish On" : @"Publish Off";
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.screenSharer disconnect];
}


- (OTAcceleratorSession *)sessionOfOTMultiPartyScreenSharer:(OTMultiPartyScreenSharer *)multiPartyScreenSharer {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] getSharedAcceleratorSession];
}

@end
