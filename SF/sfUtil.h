//
//  sfUtil.h
//  SF
//
//  Created by Mihailo Despotovic on 2/5/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sfBook.h"
#import "sfData.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)

@interface sfUtil : NSObject

+ (UITableViewCell *)makeBookCell:(NSIndexPath *)indexPath tableView:(UITableView *)tableView book:(sfBook *)book;
+ (void)addImageToBeTheSameSize:(sfBook *)b cell:(UITableViewCell *)cell;
+ (void)addCustomYearLabel:(UITableViewCell *)cell book:(sfBook *)b;
+ (NSString*)makeWebLink:(int)tag book:(sfBook *)book webSearchSyntax:(NSArray*)webSearchSyntax;
// The 2014 storyboard hard-codes white backgrounds and darkTextColor throughout,
// which ignores the system appearance. Walks a view tree swapping those for the
// semantic equivalents so the app follows Light/Dark. Images, and any view whose
// colour is deliberate (the year badge, the cover viewer's black backdrop), are
// left alone.
+ (void)applyAdaptiveColors:(UIView *)root;

+ (NSString*)appName;
+ (NSString*)appVersion;
+ (NSString*)appNameAndVersion;
+ (NSString*)replaceSerbianLetters:(NSString*)s;

@end
