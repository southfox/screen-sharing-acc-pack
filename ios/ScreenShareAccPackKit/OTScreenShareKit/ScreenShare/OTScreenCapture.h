//
//  TBScreenCapture.h
//
//  Copyright (c) 2014 TokBox Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OTVideoCapture;

/**
 * Periodically sends video frames to an OpenTok Publisher by rendering the
 * CALayer for a UIView.
 */
@interface OTScreenCapture : NSObject <OTVideoCapture>

@property UIView* view;

/**
 * Initializes a video capturer that will grab rendered stills of the view.
 */
- (instancetype)initWithView:(UIView*)view;

@end

NS_ASSUME_NONNULL_END
