//
//  DataInterface.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 20/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "DataInterface.h"
#import "StorageManager.h"

#import "QuestionBrief.h"
#import "Answer.h"

#define PAGE_NUMBER 1
#define PAGE_COUNT 20

static DataInterface * _sharedInterface = nil;

@interface DataInterface()

@property (nonatomic, strong) NetworkManager * network;
@property (nonatomic, strong) StorageManager * storage;

@end

@implementation DataInterface

#pragma mark Public

- (void)searchForTerm:(NSString *)searchTerm {
    [self makeNetworkRequestForString:[self searchQueryWithDict:@{@"page":[NSNumber numberWithInt:PAGE_NUMBER],
                                                                  @"pagesize":[NSNumber numberWithInt:PAGE_COUNT],
                                                                  @"intitle":searchTerm}]];
}

- (void)getAnswersForQuestionID:(NSString *)questionID {
    [self makeNetworkRequestForString:[self answersQueryWithDict:@{@"page":[NSNumber numberWithInt:PAGE_NUMBER],
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
    question.questionID = [NSString stringWithFormat:@"%ld", (long)[dict objectForKey:@"question_id"]];
    question.body = [dict objectForKey:@"body"];
    
    return question;
}

- (Answer *)answerFromDict:(NSDictionary *)dict {
    Answer * answer = [[Answer alloc] init];
    
    answer.questionID = [dict objectForKey:@"question_id"];
    answer.answerID = [dict objectForKey:@"answer_id"];
    answer.ownerName = [[dict objectForKey:@"owner"] objectForKey:@"display_name"];
    answer.ownerLink = [[dict objectForKey:@"owner"] objectForKey:@"link"];
    answer.votes = [[dict objectForKey:@"score"] intValue];
    answer.title = [dict objectForKey:@"title"];
    answer.body = [dict objectForKey:@"body"];
    
    return answer;
}

- (void)populateSearchResultsWithDict:(NSDictionary *)dict {
    if (!dict) { return; }
    
    NSArray * items = [dict objectForKey:@"items"];
    NSMutableArray * questions = [[NSMutableArray alloc] initWithCapacity:items.count];
    for (NSDictionary * questionDict in items) {
        QuestionBrief * question = [self questionBriefFromDict:questionDict];
        if (question) {
            [questions addObject:question];
        }
    }
    self.searchResults = questions;
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
    [searchQuery appendString:@"&filter=!9YdnSJBlX"];
    
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
    [answersQuery appendString:@"&filter=!1zSsisJjQAIq1LeCuU._i"];
    
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
    if (_delegate && [_delegate respondsToSelector:@selector(dataAvailableForType:)]) {
        [_delegate dataAvailableForType:type];
    }
}

- (NSString *)searchTermFromRequestString:(NSString *)requestString {
//    /search?pagesize=2&intitle=iOS&page=1&order=desc&sort=activity&site=stackoverflow
    
    NSString * searchTerm = nil;
    
    NSArray * dividedByAmp = [requestString componentsSeparatedByString:@"&"];
    for (NSString * string in dividedByAmp) {
        if ([string containsString:@"intitle"]) {
            NSArray * titleComponents = [string componentsSeparatedByString:@"="];
            searchTerm = [titleComponents objectAtIndex:1];
            break;
        }
    }
    return searchTerm;
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
            //save in local storage
            [_storage saveSearchData:data forSearchTerm:[self searchTermFromRequestString:requestString]];
            NSDictionary * dict = (NSDictionary *)dataObject;
            [self populateSearchResultsWithDict:dict];
            [self notifyDelegateForType:TaskTypeSearch];
        }
            break;
            
        case TaskTypeAnswers:
        {
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
