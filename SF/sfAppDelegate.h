//
//  sfAppDelegate.h
//  SF
//
//  Created by Mihailo Despotovic on 2/2/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sfData.h"

@interface sfAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) sfData *data;

@property (strong, nonatomic) UIWindow *window;

@end
