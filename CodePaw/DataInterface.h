//
//  DataInterface.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 20/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"

typedef enum {
    TaskTypeUnknown = 0,
    TaskTypeSearch,
    TaskTypeAnswers
} TaskType;

@protocol DataInterfaceProtocol <NSObject>

- (void)dataAvailableForType:(TaskType)type;

@end

@interface DataInterface : NSObject <NetworkProtocol>

+ (DataInterface *)sharedInterface;

- (NSArray *)previouslySearchedTerms;
- (void)searchForTerm:(NSString *)searchTerm;
- (void)getAnswersForQuestionID:(NSString *)questionID;

@property (nonatomic, strong) id <DataInterfaceProtocol> delegate;

//Data
@property (nonatomic, strong) NSArray * searchResults;
@property (nonatomic, strong) NSArray * answers;

@end
