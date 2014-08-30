//
//  StorageManager.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 22/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface StorageManager : NSObject

+ (StorageManager *)sharedManager;

#pragma mark Public

- (void)saveSearchData:(NSData *)data forSearchTerm:(NSString *)searchTerm andPagenumber:(unsigned int)pageNumber;
- (NSArray *)searchDataForSearchTerm:(NSString *)searchTerm;

- (void)saveAnswerData:(NSData *)data forQuestionID:(NSString *)questionID;
- (NSData *)answerDataForQuestionID:(NSString *)questionID;

- (NSArray *)previouslySearchedTerms;

@end
