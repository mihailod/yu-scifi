//
//  sfEdition.h
//  SF
//
//  Created by Mihailo Despotovic on 2/6/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sfEdition : NSObject

@property NSString *name;
@property NSString *yearsActive;
@property UIImage *image;
@property NSString *dbName;
@property NSString *publisher;
@property NSString *info;
@property NSArray *books;

@end
