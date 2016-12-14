//
//  OTMultiPartyScreenSharer.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "OTMultiPartyScreenSharer.h"
#import "OTAcceleratorSession.h"
#import "OTAcceleratorPackUtilBundle.h"
#import "OTScreenCapture.h"

#import <OTKAnalytics/OTKLogger.h>

@interface OTMultiPartyScreenShareRemote()
@property (nonatomic) OTSubscriber *subscriber;
@property (nonatomic) OTVideoView *subscriberView;
@end

@implementation OTMultiPartyScreenShareRemote

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[OTMultiPartyScreenShareRemote class]]) {
        return NO;
    }
    OTMultiPartyScreenShareRemote *subscriber = (OTMultiPartyScreenShareRemote *)object;
    if ([self.subscriber.stream.streamId isEqualToString:subscriber.subscriber.stream.streamId]) {
        return YES;
    }
    return NO;
}

- (BOOL)isRemoteAudioAvailable {
    if (!_subscriber) return NO;
    return _subscriber.stream.hasAudio;
}

- (BOOL)isRemoteVideoAvailable {
    if (!_subscriber) return NO;
    return _subscriber.stream.hasVideo;
}

- (void)setSubscribeToAudio:(BOOL)subscribeToAudio {
    if (!_subscriber) return;
    _subscriber.subscribeToAudio = subscribeToAudio;
}

- (BOOL)isSubscribeToAudio {
    if (!_subscriber) return NO;
    return _subscriber.subscribeToAudio;
}

- (void)setSubscribeToVideo:(BOOL)subscribeToVideo {
    if (!_subscriber) return;
    _subscriber.subscribeToVideo = subscribeToVideo;
}

- (BOOL)isSubscribeToVideo {
    if (!_subscriber) return NO;
    return _subscriber.subscribeToVideo;
}

- (OTVideoViewContentMode)subscriberVideoContentMode {
    if (_subscriber.viewScaleBehavior) {
        return OTVideoViewFit;
    }
    return OTVideoViewFill;
}

- (void)setSubscriberVideoContentMode:(OTVideoViewContentMode)subscriberVideoContentMode {
    if (!_subscriber || !_subscriber.view) return;
    if (subscriberVideoContentMode == OTVideoViewFit) {
        _subscriber.viewScaleBehavior = OTVideoViewScaleBehaviorFit;
    }
    else {
        _subscriber.viewScaleBehavior = OTVideoViewFill;
    }
}

- (instancetype)initWithSubscriber:(OTSubscriber *)subscriber {
    if (self = [super init]) {
        _subscriber = subscriber;
        _subscriberView = [OTVideoView defaultPlaceHolderImageWithSubscriber:self.subscriber];
    }
    return self;
}

@end

static NSString* const KLogClientVersion = @"ios-vsol-1.1.0";
static NSString* const kLogComponentIdentifier = @"multiPartyCommunication";
static NSString* const KLogActionInitialize = @"Init";
static NSString* const KLogActionStartCommunication = @"StartComm";
static NSString* const KLogActionEndCommunication = @"EndComm";
static NSString* const KLogVariationAttempt = @"Attempt";
static NSString* const KLogVariationSuccess = @"Success";
static NSString* const KLogVariationFailure = @"Failure";

@interface MultiPartyScreenShareLoggingWrapper: NSObject
@property (nonatomic) OTKLogger *logger;
@end

@implementation MultiPartyScreenShareLoggingWrapper

+ (instancetype)sharedInstance {
    
    static MultiPartyScreenShareLoggingWrapper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MultiPartyScreenShareLoggingWrapper alloc] init];
        sharedInstance.logger = [[OTKLogger alloc] initWithClientVersion:KLogClientVersion
                                                                  source:[[NSBundle mainBundle] bundleIdentifier]
                                                             componentId:kLogComponentIdentifier
                                                                    guid:[[NSUUID UUID] UUIDString]];
    });
    return sharedInstance;
}

@end

@interface OTMultiPartyScreenSharer() <OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, OTVideoViewProtocol>
@property (nonatomic) BOOL isCallEnabled;
@property (nonatomic) NSString *name;
@property (nonatomic) OTPublisher *publisher;
@property (nonatomic) NSMutableArray *subscribers;
@property (weak, nonatomic) OTAcceleratorSession *session;
@property (nonatomic) OTVideoView *publisherView;
@property (nonatomic) OTScreenCapture *screenCapture;

@property (strong, nonatomic) OTMultiPartyScreenSharerBlock handler;
@end

@implementation OTMultiPartyScreenSharer

- (void)setDataSource:(id<OTMultiPartyScreenSharerDataSource>)dataSource {
    _dataSource = dataSource;
    _session = [_dataSource sessionOfOTMultiPartyScreenSharer:self];
}

- (instancetype)init {
    
    return [self initWithName:[NSString stringWithFormat:@"%@-%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].name]];
}

- (instancetype)initWithName:(NSString *)name {
    
    [[MultiPartyScreenShareLoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationAttempt completion:nil];
    
    if (self = [super init]) {
        _name = name;
        [[MultiPartyScreenShareLoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationSuccess completion:nil];
    }
    else {
        [[MultiPartyScreenShareLoggingWrapper sharedInstance].logger logEventAction:KLogActionInitialize variation:KLogVariationFailure completion:nil];
    }
    return self;
}

- (NSError *)connectWithView:(UIView *)view {
    
    MultiPartyScreenShareLoggingWrapper *loggingWrapper = [MultiPartyScreenShareLoggingWrapper sharedInstance];
    [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                variation:KLogVariationAttempt
                               completion:nil];
    
    if (view) {
        self.screenCapture = [[OTScreenCapture alloc] initWithView:view];
    }
    NSError *connectError = [self.session registerWithAccePack:self];
    if (!connectError) {
        [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                    variation:KLogVariationSuccess
                                   completion:nil];
    }
    else {
        [loggingWrapper.logger logEventAction:KLogActionStartCommunication
                                    variation:KLogVariationFailure
                                   completion:nil];
    }
    
    return connectError;
}

- (void)connectWithView:(UIView *)view
                handler:(OTMultiPartyScreenSharerBlock)handler {
    
    if (!handler) return;
    
    self.handler = handler;
    NSError *error = [self connectWithView:view];
    if (error) {
        self.handler(OTMultiPartyScreenSharerError, nil, error);
    }
}

- (NSError *)disconnect {
    
    // need to explicitly unpublish and unsubscriber if the communicator is the only accelerator to dismiss from the common session
    // when there are multiple accelerator packs, the common session will not call the disconnect method until the last delegate object is removed
    if (self.publisher) {
        
        OTError *error = nil;
        [self.publisher.view removeFromSuperview];
        [self.session unpublish:self.publisher error:&error];
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }
        
        [self.publisherView clean];
        self.publisher = nil;
        self.publisherView = nil;
    }
    
    for (OTMultiPartyScreenShareRemote *subscriberObject in self.subscribers) {
        OTError *error = nil;
        OTSubscriber *subscriber = subscriberObject.subscriber;
        [subscriber.view removeFromSuperview];
        [self.session unsubscribe:subscriber error:&error];
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }
        [subscriberObject.subscriberView removeFromSuperview];
        [subscriberObject.subscriberView clean];
        subscriberObject.subscriber = nil;
        subscriberObject.subscriberView = nil;
        [self.subscribers removeObject:subscriberObject];
    }
    
    MultiPartyScreenShareLoggingWrapper *loggingWrapper = [MultiPartyScreenShareLoggingWrapper sharedInstance];
    NSError *disconnectError = [self.session deregisterWithAccePack:self];
    if (!disconnectError) {
        [loggingWrapper.logger logEventAction:KLogActionEndCommunication
                                    variation:KLogVariationSuccess
                                   completion:nil];
    }
    else {
        [loggingWrapper.logger logEventAction:KLogActionEndCommunication
                                    variation:KLogVariationFailure
                                   completion:nil];
    }
    
    self.isCallEnabled = NO;
    return disconnectError;
}

- (void)notifiyAllWithSignal:(OTMultiPartyScreenSharerSignal)signal
                  subscriber:(OTMultiPartyScreenShareRemote *)subscriber
                       error:(NSError *)error {
    
    if (self.handler) {
        self.handler(signal, subscriber, error);
    }
}

#pragma mark - OTSessionDelegate
-(void)sessionDidConnect:(OTSession*)session {
    
    [[MultiPartyScreenShareLoggingWrapper sharedInstance].logger setSessionId:session.sessionId
                                                                 connectionId:session.connection.connectionId
                                                                    partnerId:@([self.session.apiKey integerValue])];
    
    if (!self.publisher) {
        self.publisher = [[OTPublisher alloc] initWithDelegate:self
                                                          name:self.name
                                                    audioTrack:YES
                                                    videoTrack:YES];
        
        [self.publisher setVideoType:OTPublisherKitVideoTypeScreen];
        self.publisher.audioFallbackEnabled = NO;
        [self.publisher setVideoCapture:self.screenCapture];
    }
    
    OTError *error;
    [self.session publish:self.publisher error:&error];
    if (error) {
        [self notifiyAllWithSignal:OTMultiPartyScreenSharerError
                        subscriber:nil
                             error:error];
    }
    else {
        self.isCallEnabled = YES;
        if (!self.publisherView) {
            self.publisherView = [OTVideoView defaultPlaceHolderImageWithPublisher:self.publisher];
            self.publisherView.delegate = self;
        }
        [self notifiyAllWithSignal:OTPublisherCreated
                        subscriber:nil
                             error:nil];
    }
}

- (void)session:(OTSession *)session streamCreated:(OTStream *)stream {
    OTError *subscrciberError;
    OTSubscriber *subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    [self.session subscribe:subscriber error:&subscrciberError];
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream {
    for (OTMultiPartyScreenShareRemote *subscriberObject in _subscribers) {
        if (subscriberObject.subscriber.stream == stream) {
            OTError *error = nil;
            OTSubscriber *subscriber = subscriberObject.subscriber;
            [subscriber.view removeFromSuperview];
            [self.session unsubscribe:subscriber error:&error];
            if (error) {
                NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            }
            [subscriberObject.subscriberView removeFromSuperview];
            [subscriberObject.subscriberView clean];
            subscriberObject.subscriber = nil;
            subscriberObject.subscriberView = nil;
            [self.subscribers removeObject:subscriberObject];
        }
    }
}

- (void)sessionDidDisconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTPublisherDestroyed
                    subscriber:nil
                         error:nil];
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    [self notifiyAllWithSignal:OTMultiPartyScreenSharerError
                    subscriber:nil
                         error:error];
}

- (void)sessionDidBeginReconnecting:(OTSession *)session {
    [self notifiyAllWithSignal:OTSessionDidBeginReconnecting
                    subscriber:nil
                         error:nil];
}

- (void)sessionDidReconnect:(OTSession *)session {
    [self notifiyAllWithSignal:OTSessionDidReconnect
                    subscriber:nil
                         error:nil];
}

#pragma mark - OTPublisherDelegate
- (void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error {
    if (publisher == self.publisher) {
        [self notifiyAllWithSignal:OTMultiPartyScreenSharerError
                        subscriber:nil
                             error:error];
    }
}

- (void)subscriberDidConnectToStream:(OTSubscriber *)subscriber {
    
    OTMultiPartyScreenShareRemote *subscriberObject = [[OTMultiPartyScreenShareRemote alloc] initWithSubscriber:subscriber];
    [_subscribers addObject:subscriberObject];
    [self notifiyAllWithSignal:OTSubscriberCreated subscriber:subscriberObject error:nil];
}

- (void)subscriberDidDisconnectFromStream:(OTSubscriber *)subscriber {
    
    OTMultiPartyScreenShareRemote *subscriberObject = [[OTMultiPartyScreenShareRemote alloc] initWithSubscriber:subscriber];
    if ([_subscribers containsObject:subscriberObject]) {
        [_subscribers removeObject:subscriberObject];
    }
    [self notifiyAllWithSignal:OTSubscriberDestroyed subscriber:subscriberObject error:nil];
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error {
    
    OTMultiPartyScreenShareRemote *subscriberObject = [[OTMultiPartyScreenShareRemote alloc] initWithSubscriber:subscriber];
    [self notifiyAllWithSignal:OTSubscriberDestroyed subscriber:subscriberObject error:nil];
}

#pragma mark - OTVideoViewProtocol
- (void)placeHolderImageViewDidShowOnVideoView:(OTVideoView *)videoView {
    
}

- (void)placeHolderImageViewDidDismissOnVideoView:(OTVideoView *)videoView {
    
}

- (void)setPublishAudio:(BOOL)publishAudio {
    if (!_publisher) return;
    _publisher.publishAudio = publishAudio;
}

- (BOOL)isPublishAudio {
    if (!_publisher) return NO;
    return _publisher.publishAudio;
}

- (void)setPublishVideo:(BOOL)publishVideo {
    if (!_publisher) return;
    _publisher.publishVideo = publishVideo;
}

- (BOOL)isPublishVideo {
    if (!_publisher) return NO;
    return _publisher.publishVideo;
}

- (AVCaptureDevicePosition)cameraPosition {
    return _publisher.cameraPosition;
}

- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    _publisher.cameraPosition = cameraPosition;
}

@end

