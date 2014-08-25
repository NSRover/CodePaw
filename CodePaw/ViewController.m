//
//  ViewController.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 20/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "ViewController.h"

#import "QuestionBrief.h"
#import "Answer.h"

@interface ViewController ()

@property (nonatomic, strong) DataInterface * dataInterface;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataInterface = [DataInterface sharedInterface];
    _dataInterface.delegate = self;
//    [[DataInterface sharedInterface] searchForTerm:@"c++"];
    [[DataInterface sharedInterface] getAnswersForQuestionID:@"22734157"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Data protocol

- (void)dataAvailableForType:(TaskType)type {
//    QuestionBrief * question = [_dataInterface.searchResults objectAtIndex:0];
//    NSLog(@"Title : %@", question.title);
//    NSLog(@"Body : %@", question.body);
    
    Answer * answer = [_dataInterface.answers objectAtIndex:0];
    NSLog(@"Title: %@", answer.title);
    NSLog(@"Body: %@", answer.body);
}

@end
