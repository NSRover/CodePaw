//
//  QuestionBrief.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 20/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionBrief : NSObject

@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSString * ownerName;
@property (nonatomic, strong) NSString * ownerLink;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSString * questionID;
@property (nonatomic, assign) unsigned int votes;
@property (nonatomic, assign) unsigned int numberOfAnswers;

@end
