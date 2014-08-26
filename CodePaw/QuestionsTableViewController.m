//
//  QuestionsTableViewController.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 26/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "QuestionsTableViewController.h"

#import "QuestionTableViewCell.h"
#import "QuestionBrief.h"
#import "QuestionViewController.h"

@interface QuestionsTableViewController ()

@property (nonatomic, strong) DataInterface * dataInterface;
@property (nonatomic, strong) QuestionBrief * targetQuestion;

@end

@implementation QuestionsTableViewController

#pragma mark Navigation

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"Question for %@", _searchTerm];
    
    self.dataInterface = [DataInterface sharedInterface];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QuestionViewController * questionViewController = (QuestionViewController *)[segue destinationViewController];
    questionViewController.question = _targetQuestion;
}

#pragma mark Data protocol

- (void)dataAvailableForType:(TaskType)type {
    //In case of new data, refresh
    if (type == TaskTypeSearch) {
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataInterface.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QuestionBrief * question = [_dataInterface.searchResults objectAtIndex:indexPath.row];
    
    QuestionTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"questionCell" forIndexPath:indexPath];
    
    cell.questionTitle.text = question.title;
    cell.score.text = [NSString stringWithFormat:@"Score: %d", question.votes];
    cell.answers.text = [NSString stringWithFormat:@"Answers: %d", question.numberOfAnswers];
    cell.ownerName.text = question.ownerName;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.targetQuestion = [_dataInterface.searchResults objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"pushQuestion" sender:self];
}

@end
