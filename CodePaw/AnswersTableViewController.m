//
//  AnswersTableViewController.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 28/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "AnswersTableViewController.h"
#import "AnswerTableViewCell.h"
#import "AnswerViewController.h"
#import "Answer.h"

@interface AnswersTableViewController ()

@property (nonatomic, strong) DataInterface * dataInterface;
@property (nonatomic, strong) Answer * targetAnswer;
@end

@implementation AnswersTableViewController

#pragma mark Navigation

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataInterface = [DataInterface sharedInterface];
    _dataInterface.delegate = self;
    
    if (!_dataInterface.answers || _dataInterface.answers.count == 0) {
        [_dataInterface getAnswersForQuestionID:_questionID];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AnswerViewController * answerViewController = (AnswerViewController *)[segue destinationViewController];
    answerViewController.answer = _targetAnswer;
}

#pragma mark DataInterface delegate

- (void)dataAvailableForType:(TaskType)type {
    if (type == TaskTypeAnswers) {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataInterface.answers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Answer * answer = [_dataInterface.answers objectAtIndex:indexPath.row];
    AnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"answerCell" forIndexPath:indexPath];
    
    NSAttributedString * attrbody = [[NSAttributedString alloc] initWithData:[answer.body
                                                                              dataUsingEncoding:NSUnicodeStringEncoding]
                                                                     options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                          documentAttributes:nil
                                                                       error:nil];

    cell.answerTitle.attributedText = attrbody;
    cell.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", answer.votes];
    cell.answeredBy.text = answer.ownerName;
    
    return cell;
}

#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.targetAnswer = [_dataInterface.answers objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"pushAnswer" sender:nil];
}

@end
