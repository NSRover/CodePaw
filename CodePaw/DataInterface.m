//
//  DataInterface.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 20/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "DataInterface.h"
#import <UIKit/UIKit.h>
#import "StorageManager.h"

#import "QuestionBrief.h"
#import "Answer.h"

#define START_PAGE_NUMBER 1
#define PAGE_COUNT 5
#define MAX_RESULTS 30

static DataInterface * _sharedInterface = nil;

@interface DataInterface()

@property (nonatomic, strong) NetworkManager * network;
@property (nonatomic, strong) StorageManager * storage;

@property (nonatomic, strong) NSString * currentSearchTerm;

@end

@implementation DataInterface

#pragma mark Public

- (NSArray *)previouslySearchedTerms {
    return [_storage previouslySearchedTerms];
}

- (void)searchForTerm:(NSString *)searchTerm {

    self.currentSearchTerm = searchTerm;
    if (!_currentSearchTerm) { return; }
    
    //Return result from cache
    [self provideLocalDataForSearchTerm:searchTerm];
    
    //Make a network request
    [self networkSearchForTerm:searchTerm pageNumber:START_PAGE_NUMBER];
}

- (void)getAnswersForQuestionID:(NSString *)questionID {
    
    //Return from cache
    [self provideLocalAnswersForQuestionID:questionID];

    //Network request
    [self makeNetworkRequestForString:[self answersQueryWithDict:@{@"page":[NSNumber numberWithInt:START_PAGE_NUMBER],
                                                                  @"pagesize":[NSNumber numberWithInt:PAGE_COUNT],
                                                                  @"question_id":questionID}]];
}

#pragma mark Parsing

- (QuestionBrief *)questionBriefFromDict:(NSDictionary *)dict {
    QuestionBrief * question = [[QuestionBrief alloc] init];
    
    question.link = [dict objectForKey:@"link"];
    question.ownerName = [[dict objectForKey:@"owner"] objectForKey:@"display_name"];
    question.ownerLink = [[dict objectForKey:@"owner"] objectForKey:@"link"];
    question.title = [dict objectForKey:@"title"];
    question.votes = [[dict objectForKey:@"score"] intValue];
    question.numberOfAnswers = [[dict objectForKey:@"answer_count"] intValue];
    question.questionID = [NSString stringWithFormat:@"%@", (NSNumber *)[dict objectForKey:@"question_id"]];
    question.body = [dict objectForKey:@"body"];
    
    return question;
}

- (Answer *)answerFromDict:(NSDictionary *)dict {
    Answer * answer = [[Answer alloc] init];
    
    answer.questionID = [NSString stringWithFormat:@"%ld", (long)[dict objectForKey:@"question_id"]];
    answer.answerID = [dict objectForKey:@"answer_id"];
    answer.ownerName = [[dict objectForKey:@"owner"] objectForKey:@"display_name"];
    answer.ownerLink = [[dict objectForKey:@"owner"] objectForKey:@"link"];
    answer.votes = [[dict objectForKey:@"score"] intValue];
    answer.title = [dict objectForKey:@"title"];
    answer.body = [dict objectForKey:@"body"];
    
    return answer;
}

- (NSArray *)searchResultsWithDict:(NSDictionary *)dict {
    if (!dict) { return nil; }
    
    NSArray * items = [dict objectForKey:@"items"];
    NSMutableArray * questions = [[NSMutableArray alloc] initWithCapacity:items.count];
    for (NSDictionary * questionDict in items) {
        QuestionBrief * question = [self questionBriefFromDict:questionDict];
        if (question) {
            [questions addObject:question];
        }
    }
    return questions;
}

- (void)populateAnswersResultWithDict:(NSDictionary *)dict {
    if (!dict) { return; }
    
    NSArray * items = [dict objectForKey:@"items"];
    NSMutableArray * answers = [[NSMutableArray alloc] initWithCapacity:items.count];
    for (NSDictionary * answerDict in items) {
        Answer * answer = [self answerFromDict:answerDict];
        if (answer) {
            [answers addObject:answer];
        }
    }
    self.answers = answers;
}

#pragma mark Logic

- (void)networkSearchForTerm:(NSString *)searchTerm pageNumber:(unsigned int)pageNumber {
    [self makeNetworkRequestForString:[self searchQueryWithDict:@{@"page":[NSNumber numberWithInt:pageNumber],
                                                                  @"pagesize":[NSNumber numberWithInt:PAGE_COUNT],
                                                                  @"intitle":searchTerm}]];
}

- (void)provideLocalDataForSearchTerm:(NSString *)searchTerm {
    
    NSArray * dataList = [_storage searchDataForSearchTerm:searchTerm];
    
    if (dataList.count > 0) {
        for (NSData * data in dataList) {
            if (data) {
                [self useData:data forSearchTerm:searchTerm isNetworkRequest:NO];
            }
        }
    }
    else {
        self.searchResults = nil;
    }
    
    [self notifyDelegateForType:TaskTypeSearch];
}

- (void)useData:(NSData *)data forSearchTerm:(NSString *)searchTerm isNetworkRequest:(BOOL)networkRequest {
    
    NSError * error;
    id dataObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:&error];
    if (error) {
        NSLog(@"* DataInterface - error parsing data for search Term %@ \n Error - %@", searchTerm, [error description]);
    }
    
    NSDictionary * dict = (NSDictionary *)dataObject;
    
    //Check if there was an error
    NSString * error_name = [dict objectForKey:@"error_name"];
    NSString * error_message = [dict objectForKey:@"error_message"];
    if (error_name) {
        [[[UIAlertView alloc] initWithTitle:error_name
                                    message:error_message
                                   delegate:nil
                          cancelButtonTitle:@":("
                          otherButtonTitles:nil, nil] show];
        return;
    }
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    unsigned int pageNumber = [[dict objectForKey:@"page"] intValue];
    
    if (pageNumber > 1) {
        [array addObjectsFromArray:_searchResults];
    }
    
    [array addObjectsFromArray:[self searchResultsWithDict:dict]];
    
    self.searchResults = array;

    //queue next page
    //check if
    if (networkRequest && _currentSearchTerm && [_currentSearchTerm isEqualToString:searchTerm]) {
        unsigned int more = [[dict objectForKey:@"has_more"] intValue];
        if (more == 1 && (_searchResults.count < MAX_RESULTS)) {
            [self networkSearchForTerm:searchTerm pageNumber:(pageNumber + 1)];
        }
        
        //save in local storage
        [_storage saveSearchData:data forSearchTerm:searchTerm andPagenumber:pageNumber];
    }
}

- (void)provideLocalAnswersForQuestionID:(NSString *)questionID {
    NSData * data = [_storage answerDataForQuestionID:questionID];
    if (data) {
        [self useData:data forAnswersToQeustionID:questionID];
    }
    else {
        self.answers = nil;
        [self notifyDelegateForType:TaskTypeAnswers];
    }
}

- (void)useData:(NSData *)data forAnswersToQeustionID:(NSString *)questionID {
    NSError * error;
    id dataObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:&error];
    if (error) {
        NSLog(@"* DataInterface - error parsing data for answers to question ID %@ \n Error - %@", questionID, [error description]);
    }
    
    
    NSDictionary * dict = (NSDictionary *)dataObject;
    [self populateAnswersResultWithDict:dict];
    [self notifyDelegateForType:TaskTypeAnswers];
}

#pragma mark Helpers

- (void)makeNetworkRequestForString:(NSString *)requestString {
    [_network startRequestWithString:requestString];
}

- (NSString *)searchQueryWithDict:(NSDictionary *)dict {
    NSMutableString * searchQuery = [[NSMutableString alloc] initWithFormat:@"/search"];
    for (int ii = 0; ii < [[dict allKeys] count]; ii++) {
        //Prefix
        NSString * prefix = @"&";
        if (ii == 0) {
            prefix = @"?";
        }
        [searchQuery appendString:prefix];
        
        NSString * key = [[dict allKeys] objectAtIndex:ii];
        if ([key isEqualToString:@"page"]) {
            [searchQuery appendFormat:@"page=%d", [[dict objectForKey:key] intValue]];
        }
        else if ([key isEqualToString:@"pagesize"]) {
            [searchQuery appendFormat:@"pagesize=%d", [[dict objectForKey:key] intValue]];
        }
        else if ([key isEqualToString:@"intitle"]) {
            [searchQuery appendFormat:@"intitle=%@", [dict objectForKey:key]];
        }
    }
    
    //Add mandatory
    [searchQuery appendString:@"&order=desc&sort=activity"];
    //Add site
    [searchQuery appendString:@"&site=stackoverflow"];
    //Add filter to include body
//    [searchQuery appendString:@"&filter=!9YdnSJBlX"];
    [searchQuery appendString:@"&filter=!)EhxhBhwjEQKdIU7QuJvkN-ZQ-vSBWkGzU7urbnAouC9wtX)V"];
    
    return searchQuery;
}

- (NSString *)answersQueryWithDict:(NSDictionary *)dict {
    NSMutableString * answersQuery = [[NSMutableString alloc] initWithFormat:@"/questions"];
    
    //question id
    [answersQuery appendFormat:@"/%@/answers?", [dict objectForKey:@"question_id"]];
    //Page
    [answersQuery appendFormat:@"page=%d", [[dict objectForKey:@"page"] intValue]];
    [answersQuery appendFormat:@"&pagesize=%d", [[dict objectForKey:@"pagesize"] intValue]];
    
    //Add mandatory
    [answersQuery appendString:@"&order=desc&sort=activity"];
    //Add site
    [answersQuery appendString:@"&site=stackoverflow"];
    //Add filter for body
    [answersQuery appendString:@"&filter=!4*SyY(4Kifp0M9dZX"];
    
    return answersQuery;
}

- (TaskType)typeForRequestString:(NSString *)requestString {
    TaskType type = TaskTypeUnknown;
    NSString * prefix = [[requestString componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] objectAtIndex:1]; //! Dirty logic for api type, fix
    if ([prefix isEqualToString:@"search"]) {
        type = TaskTypeSearch;
    }
    else if ([prefix isEqualToString:@"questions"]) {
        type = TaskTypeAnswers;
    }
    return type;
}

- (void)notifyDelegateForType:(TaskType)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(dataAvailableForType:)]) {
            [_delegate dataAvailableForType:type];
        }
    });
}

- (NSString *)searchTermFromRequestString:(NSString *)requestString {
//    /search?pagesize=2&intitle=iOS&page=1&order=desc&sort=activity&site=stackoverflow
    
    NSString * searchTerm = nil;
    
    NSArray * dividedByAmp = [requestString componentsSeparatedByString:@"&"];
    for (NSString * string in dividedByAmp) {
        if ([string rangeOfString:@"intitle"].location != NSNotFound) {
            NSArray * titleComponents = [string componentsSeparatedByString:@"="];
            searchTerm = [titleComponents objectAtIndex:1];
            break;
        }
    }
    return searchTerm;
}

- (NSString *)questionIDFromRequestString:(NSString *)requestString {
    
    NSArray * dividedBySlash = [requestString componentsSeparatedByString:@"/"];
    NSString * questionID = [dividedBySlash objectAtIndex:2];

    return questionID;
}

#pragma mark Initialization

+ (DataInterface *)sharedInterface {
    if (!_sharedInterface) {
        _sharedInterface = [[DataInterface alloc] initCustom];
    }
    return _sharedInterface;
}

- (id)init {
    NSLog(@"* DataInterface - Cannot create object this way, its a singleton");
    return nil;
}

- (id)initCustom {
    self = [super init];
    
    self.network = [NetworkManager sharedManager];
    _network.delegate = self;
    
    self.storage = [StorageManager sharedManager];
    
    return self;
}

#pragma mark Network Protocol

- (void)receivedData:(NSData *)data forRequestURLString:(NSString *)requestString {
    //Convert JSON
    NSError * error;
    id dataObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:&error];
    if (error) {
        NSLog(@"* DataInterface - error getting data for request %@ \n Error - %@", requestString, [error description]);
    }
    
    switch ([self typeForRequestString:requestString]) {
        case TaskTypeUnknown:
            NSLog(@"* DataInterface - Cannot determine the type for responce");
            break;
            
        case TaskTypeSearch:
        {
            NSString * searchTerm = [self searchTermFromRequestString:requestString];
            
            //ignore response of older requests
            if (![searchTerm isEqualToString:_currentSearchTerm]) {
                return;
            }
            
            //Use
            [self useData:data forSearchTerm:searchTerm isNetworkRequest:YES];
            
            //Notify delegates
            [self notifyDelegateForType:TaskTypeSearch];
        }
            break;
            
        case TaskTypeAnswers:
        {
            //save in local storage
            [_storage saveAnswerData:data forQuestionID:[self questionIDFromRequestString:requestString]];
            NSDictionary * dict = (NSDictionary *)dataObject;
            [self populateAnswersResultWithDict:dict];
            [self notifyDelegateForType:TaskTypeAnswers];
        }
            break;

        default:
            break;
    }
}

@end
