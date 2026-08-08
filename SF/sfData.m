//
//  sfData.m
//  SF
//
//  Created by Mihailo Despotovic on 2/2/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import "sfData.h"

#define MISSING_IMAGE_NAME @"missingimage"

@implementation sfData

@synthesize allEditions;
@synthesize totalNumberOfItems;

@synthesize webSearchSyntax;

- (id) init {
    self = [super init];
    [self populateEditions];
    for (int i=0; i<allEditions.count; i++) {
        sfEdition *e = [allEditions objectAtIndex:i];
        e.books = [self readBooksForDatabase:e.dbName forEdition:e.name];
        totalNumberOfItems += [e.books count];
    }
    // All six re-derived against the live sites on 2026-08-07. The 2014 paths are
    // dead: Limundo moved pretragaLimundo.php -> /pretraga, Njuskalo and Bolha both
    // moved to /search/?keywords=, and Kupindo kept pretraga.php but retired the
    // Grupa=405 category id (which 404s). Category filtering is gone on all four
    // marketplaces; title searches come back clean without it.
    webSearchSyntax = [NSArray arrayWithObjects:
                       @"https://www.google.com/search?q=",
                       @"https://en.m.wikipedia.org/wiki/Special:Search?search=",
                       @"https://www.goodreads.com/search?q=",
                       @"https://www.limundo.com/pretraga?txtPretraga=",
                       @"https://www.kupindo.com/pretraga.php?bSearchBox=1&Pretraga=",
                       @"https://www.njuskalo.hr/search/?keywords=",
                       @"https://www.bolha.com/search/?keywords=",
                       @"https://olx.ba/pretraga?q=",
                       nil];
    
    return self;
}

- (NSArray *)readBooksForDatabase:(NSString *)dbName forEdition:(NSString *)editionName {
    NSString* path = [[NSBundle mainBundle] pathForResource:dbName ofType:@"txt"];
    NSError *error = nil;
    NSString* db = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if(error) { NSLog(@"ERROR while loading from file: %@", error); }
    NSString *dummy = @"#$%^&";
    db = [db stringByReplacingOccurrencesOfString:@"\n" withString:dummy];
    NSArray *lines = [[NSArray alloc] initWithArray:[db componentsSeparatedByString:dummy]];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    sfBook *b;
    for (int i=0; i<lines.count; i++) {
        NSString *line = [lines objectAtIndex:i];
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (line.length == 0 || [line hasPrefix:@"#"]) {
            continue;
        }
        NSArray *fields = [[NSArray alloc] initWithArray:[line componentsSeparatedByString:@"|"]];
        b = [[sfBook alloc] init];
        b.edicija = editionName;
        b.naslov = [fields objectAtIndex:0];
        b.title = [fields objectAtIndex:1];
        b.autor = [fields objectAtIndex:2];
        b.author = [fields objectAtIndex:3];
        b.yearWritten = [fields objectAtIndex:4];
        b.godinaIzdanja = [fields objectAtIndex:5];
        if ([[fields objectAtIndex:6] length] > 0) {
            b.image = [UIImage imageNamed:[fields objectAtIndex:6]];
        }
        if (b.image == nil) {
            NSString *defaultImageName = [[b.naslov stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
            defaultImageName = [sfUtil replaceSerbianLetters:defaultImageName];
            if ([defaultImageName length] > 0) {
                b.image = [UIImage imageNamed:defaultImageName];
            }
            if (b.image == nil) {
                b.image = [UIImage imageNamed:MISSING_IMAGE_NAME];
            }
        }
        b.prevodilac = [fields objectAtIndex:7];
        b.serija = [fields objectAtIndex:8];
        b.serial = [fields objectAtIndex:9];
        [mutableArray addObject:b];
    }
    NSArray *array = [NSArray arrayWithArray:mutableArray];
    return array;
}

- (void)populateEditions
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"editionsdb" ofType:@"txt"];
    NSError *error = nil;
    NSString* db = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if(error) { NSLog(@"ERROR while loading from file: %@", error); }
    NSString *dummy = @"#$%^&";
    db = [db stringByReplacingOccurrencesOfString:@"\n" withString:dummy];
    NSArray *lines = [[NSArray alloc] initWithArray:[db componentsSeparatedByString:dummy]];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    sfEdition *e;
    for (int i=0; i<lines.count; i++) {
        NSString *line = [lines objectAtIndex:i];
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (line.length == 0) {
            continue;
        }
        NSArray *fields = [[NSArray alloc] initWithArray:[line componentsSeparatedByString:@"|"]];
        e = [[sfEdition alloc] init];
        e.name = [fields objectAtIndex:0];
        e.yearsActive = [fields objectAtIndex:1];
        e.image = [UIImage imageNamed:[fields objectAtIndex:2]];
        if (e.image == nil) {
            e.image = [UIImage imageNamed:MISSING_IMAGE_NAME];
        }
        e.dbName = [fields objectAtIndex:3];
        e.publisher =[fields objectAtIndex:4];
        e.info = [fields objectAtIndex:5];
        e.info = [e.info stringByReplacingOccurrencesOfString:@"\n" withString:@" - "];
        [mutableArray addObject:e];
    }
    allEditions = [NSArray arrayWithArray:mutableArray];
}

- (void)searchBooksArray:(NSArray *)array :(NSString *)text :(NSMutableArray *)result {
    for (int i=0; i<array.count; i++) {
        sfBook *b = [array objectAtIndex:i];
        
        NSString *s = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@",
                       b.edicija, b.naslov, b.title, b.autor, b.author,
                       b.yearWritten, b.godinaIzdanja, b.prevodilac, b.serija, b.serial];
        NSRange r = [s rangeOfString:text options:NSCaseInsensitiveSearch];
        if (r.location != NSNotFound) {
            [result addObject:b];
        } else {
            // curcic = ćurčić
            s = [sfUtil replaceSerbianLetters:s];
            r = [s rangeOfString:text options:NSCaseInsensitiveSearch];
            if (r.location != NSNotFound) {
                [result addObject:b];
            }
        }
    }
}

- (NSArray *) search:(NSString *)text {
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    for (int i=0; i<allEditions.count; i++) {
        NSArray *books = [[allEditions objectAtIndex:i] books];
        [self searchBooksArray:books :text :searchResults];
    }
    return searchResults;
}

@end
