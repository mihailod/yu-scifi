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

+(NSString*)appStoreUrl
{
    return [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", APP_STORE_ID];
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
    if ((tag == GOOGLE || tag == WIKIPEDIA) && book.title.length > 0) {
        searchKeyword = book.title;
    } else {
        searchKeyword = book.naslov;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [webSearchSyntax objectAtIndex:tag], [sfUtil encodeURL:searchKeyword]];
    return urlString;
}

+ (NSString*)encodeURL:(NSString *)string
{
    NSString *newString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    if (newString) return newString;
    else return @"";
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
