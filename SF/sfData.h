//
//  sfData.h
//  SF
//
//  Created by Mihailo Despotovic on 2/2/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sfBook.h"
#import "sfEdition.h"
#import "sfUtil.h"

#define EDITION_OSTALO @"Ostalo"
#define EDITION_TEORIJA @"Teorija"

#define GOOGLE 0
#define WIKIPEDIA 1
#define LIMUNDO 2
#define KUPINDO 3
#define NJUSKALO 4
#define BOLHA 5

@interface sfData : NSObject

@property NSArray *allEditions;
@property int totalNumberOfItems;

@property NSArray *webSearchSyntax;

- (NSArray *) search:(NSString *)text;

@end
