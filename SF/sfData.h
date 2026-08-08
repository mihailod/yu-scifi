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

// These are button tags in the storyboard as well as indices into
// webSearchSyntax -- the two must stay in step.
#define GOOGLE 0
#define WIKIPEDIA 1
#define GOODREADS 2
#define LIMUNDO 3
#define KUPINDO 4
#define NJUSKALO 5
#define BOLHA 6
#define OLX 7

@interface sfData : NSObject

@property NSArray *allEditions;
@property int totalNumberOfItems;

@property NSArray *webSearchSyntax;

- (NSArray *) search:(NSString *)text;

@end
