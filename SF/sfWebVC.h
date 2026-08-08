//
//  sfWebVC.h
//  SF
//
//  Created by Mihailo Despotovic on 2/9/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sfWebVC : UIViewController

@property IBOutlet UIWebView *webView;
@property IBOutlet UIButton *back;
@property IBOutlet UIButton *forward;

@property NSString *urlString;

- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;

@end
