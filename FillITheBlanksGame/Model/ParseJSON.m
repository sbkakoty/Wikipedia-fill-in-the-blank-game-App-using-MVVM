//
//  ParseJSON.m
//  FillITheBlanksGame
//
//  Created by MacBook on 8/23/22.
//

#import <Foundation/Foundation.h>
#import "ParseJSON.h"

@implementation ParseJSON

-(NSString *)parse: (NSDictionary *)pageData {
    
    NSString *keyName = NULL;
    NSDictionary *query = [pageData objectForKey:@"query"];
    NSDictionary *pages = [query objectForKey:@"pages"];
    
    for (NSString* key in pages) {
        keyName = key;
    }
    
    NSDictionary *someVale = [pages objectForKey:keyName];
    NSString *extract = [someVale objectForKey:@"extract"];
    
    return extract;
}

@end
