//
//  sfUtil.m
//  SF
//
//  Created by Mihailo Despotovic on 2/5/14.
//  Copyright (c) 2014 MiRteh. All rights reserved.
//

#import "sfUtil.h"

#define CELL_REUSE_ID @"Cell"
#define TAG_YEAR_LABEL 2
#define TAG_IMAGE 1

#define BOOK_CELL_IMAGE_X 7.5
#define BOOK_CELL_IMAGE_WIDTH 25
#define DEFAULT_CELL_FONT_SIZE 17

@implementation sfUtil

// A colour counts as "hard-coded light" if it is opaque and near-white. Matching
// on the value rather than the view class means the storyboard's mix of
// calibratedWhite and calibratedRGB whites is all caught by one rule.
static BOOL sfIsOpaqueNearWhite(UIColor *c)
{
    if (c == nil) { return NO; }
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if (![c getRed:&r green:&g blue:&b alpha:&a]) { return NO; }
    return (a > 0.99f && r > 0.95f && g > 0.95f && b > 0.95f);
}

+ (void)applyAdaptiveColors:(UIView *)root
{
    if (root == nil) { return; }

    // Tagged views are the deliberately-coloured ones (year badge over cover art)
    // and must keep their own contrast independent of appearance.
    if (root.tag == TAG_YEAR_LABEL || root.tag == TAG_IMAGE) { return; }

    if ([root isKindOfClass:[UIImageView class]]) { return; }

    if (sfIsOpaqueNearWhite(root.backgroundColor)) {
        root.backgroundColor = [UIColor systemBackgroundColor];
    }

    if ([root isKindOfClass:[UILabel class]]) {
        UILabel *l = (UILabel *)root;
        // darkTextColor is a fixed black; labelColor is the adaptive counterpart.
        if ([l.textColor isEqual:[UIColor darkTextColor]] || [l.textColor isEqual:[UIColor blackColor]]) {
            l.textColor = [UIColor labelColor];
        }
    }

    if ([root isKindOfClass:[UITextView class]]) {
        UITextView *t = (UITextView *)root;
        t.backgroundColor = [UIColor clearColor];
        t.textColor = [UIColor labelColor];
    }

    for (UIView *sub in root.subviews) {
        [self applyAdaptiveColors:sub];
    }
}

+(NSString*)appName
{
    //return @"Wikipanion";
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
    return prodName;
}

+(NSString*)appVersion
{
    //NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return appVersionString;
    //NSString *versionBuildString = [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString];
    //return versionBuildString;
}

+(NSString*)appNameAndVersion
{
    return [NSString stringWithFormat:@"%@ %@", [self appName], [self appVersion]];
}

+ (UITableViewCell *)makeBookCell:(NSIndexPath *)indexPath tableView:(UITableView *)tableView book:(sfBook *)book
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_REUSE_ID /*forIndexPath:indexPath*/];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_REUSE_ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setIndentationLevel:3]; // move text a bit since the image is layed in a custom way
    }
    //cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_REUSE_ID];
    cell.textLabel.font = [UIFont systemFontOfSize:DEFAULT_CELL_FONT_SIZE];
    if ([[book naslov] length] > 30) {
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    if ([[book naslov] length] > 34) {
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    if ([[book naslov] length] > 38) {
        cell.textLabel.font = [UIFont systemFontOfSize:9];
    }
    cell.textLabel.text = book.naslov;
    cell.detailTextLabel.text = book.autor;
    
    [sfUtil addImageToBeTheSameSize:book cell:cell];
    [sfUtil addCustomYearLabel:cell book:book];
    
    return cell;
}

+ (void)addImageToBeTheSameSize:(sfBook *)b cell:(UITableViewCell *)cell
{
    if (![cell.contentView viewWithTag:TAG_IMAGE]) {
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(BOOK_CELL_IMAGE_X, 1.5, BOOK_CELL_IMAGE_WIDTH, 40)];
        imgView.backgroundColor=[UIColor clearColor];
        [imgView.layer setCornerRadius:1.0f]; // rounded rectangles!
        [imgView.layer setMasksToBounds:YES];
        [imgView setImage:b.image];
        [imgView setTag:TAG_IMAGE];
        [cell.contentView addSubview:imgView];
    }
    [((UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE]) setImage:b.image];
}

+ (void)addCustomYearLabel:(UITableViewCell *)cell book:(sfBook *)b
{
    if (![cell.contentView viewWithTag:TAG_YEAR_LABEL]) {
        UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(BOOK_CELL_IMAGE_X, 35, BOOK_CELL_IMAGE_WIDTH, 7.5)];
        yearLabel.font = [UIFont systemFontOfSize:8.0];
        yearLabel.textAlignment = NSTextAlignmentCenter;
        yearLabel.textColor = [UIColor whiteColor];
        yearLabel.backgroundColor = [UIColor blackColor];
        [yearLabel setTag:TAG_YEAR_LABEL];
        [cell.contentView addSubview:yearLabel];
    }
    [((UILabel *)[cell.contentView viewWithTag:TAG_YEAR_LABEL]) setText:(b.godinaIzdanja.length > 0 ? b.godinaIzdanja : @"????")];
}

+ (NSString*) makeWebLink:(int)tag book:(sfBook *)book webSearchSyntax:(NSArray*)webSearchSyntax
{
    NSString *searchKeyword;
    // Google, Wikipedia and Goodreads are catalogued in English, so prefer the
    // original title where we have it; the Balkan marketplaces list the local
    // edition and need the translated title.
    BOOL preferOriginal = (tag == GOOGLE || tag == WIKIPEDIA || tag == GOODREADS);
    BOOL haveOriginal = preferOriginal && book.title.length > 0;

    searchKeyword = haveOriginal ? book.title : book.naslov;

    // Google alone gets the author appended: plenty of original titles are
    // ordinary phrases ("Way Station", "The Wall") and drown on their own.
    // Wikipedia and Goodreads search their own book catalogues, where the bare
    // title is the better query. Keep the author in the same language as the
    // title so the pair reads as one work.
    if (tag == GOOGLE) {
        NSString *author = haveOriginal ? book.author : book.autor;
        if (author.length > 0) {
            searchKeyword = [NSString stringWithFormat:@"%@ %@", searchKeyword, author];
        }
    }

    return [sfUtil makeWebLink:tag keyword:searchKeyword webSearchSyntax:webSearchSyntax];
}

// Same, but for callers that have already chosen the search term -- the Goodreads
// button lets the reader pick between the original and translated title.
+ (NSString*) makeWebLink:(int)tag keyword:(NSString *)keyword webSearchSyntax:(NSArray*)webSearchSyntax
{
    if (tag < 0 || tag >= (int)webSearchSyntax.count) { return nil; }
    return [NSString stringWithFormat:@"%@%@", [webSearchSyntax objectAtIndex:tag], [sfUtil encodeURL:keyword]];
}

+ (NSString*)encodeURL:(NSString *)string
{
    // Replaces CFURLCreateStringByAddingPercentEscapes, which is deprecated and
    // was also leaking here: it returns a +1 CFString and the old __bridge cast
    // never handed that reference to ARC.
    //
    // The allowed set is spelled out rather than using +alphanumericCharacterSet
    // because that set omits - . _ (which the old code passed through) and
    // includes every Unicode letter, so it would not document what actually
    // survives encoding. Non-ASCII needs no special handling either way:
    // -stringByAddingPercentEncodingWithAllowedCharacters: UTF-8 encodes it
    // regardless of the allowed set, so "Zadužbina" -> "Zadu%C5%BEbina".
    //
    // Verified byte-identical to the old implementation across all 1005 titles
    // in the catalogue plus diacritic, Cyrillic and emoji cases.
    static NSCharacterSet *allowed = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *set = [[NSMutableCharacterSet alloc] init];
        [set addCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                    "abcdefghijklmnopqrstuvwxyz"
                                    "0123456789-._"];
        allowed = [set copy];
    });

    NSString *encoded = [string stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    return encoded ?: @"";
}

+ (NSString*)replaceSerbianLetters:(NSString*)s
{
    s = [s stringByReplacingOccurrencesOfString:@"ć" withString:@"c"];
    s = [s stringByReplacingOccurrencesOfString:@"Ć" withString:@"C"];
    s = [s stringByReplacingOccurrencesOfString:@"š" withString:@"s"];
    s = [s stringByReplacingOccurrencesOfString:@"Š" withString:@"S"];
    s = [s stringByReplacingOccurrencesOfString:@"č" withString:@"c"];
    s = [s stringByReplacingOccurrencesOfString:@"Č" withString:@"c"];
    s = [s stringByReplacingOccurrencesOfString:@"ž" withString:@"z"];
    s = [s stringByReplacingOccurrencesOfString:@"Ž" withString:@"Z"];
    return s;
}

@end
