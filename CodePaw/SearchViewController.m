//
//  SearchViewController.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 26/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "SearchViewController.h"

#import "QuestionBrief.h"
#import "Answer.h"
#import "PreviouslySearchedTermTableViewCell.h"

#import "QuestionsTableViewController.h"

@interface SearchViewController ()

@property (nonatomic, strong) DataInterface * dataInterface;
@property (nonatomic, strong) NSArray * previousSearchTerms;
@property (nonatomic, strong) NSString * searchTerm;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *overlayLabel;
@end

@implementation SearchViewController

#pragma mark Navigation

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Update UI
    [self initialUISetup];
    
    self.dataInterface = [DataInterface sharedInterface];
    
    self.previousSearchTerms = [_dataInterface previouslySearchedTerms];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QuestionsTableViewController * questionsViewController = (QuestionsTableViewController *)[segue destinationViewController];
    questionsViewController.searchTerm = _searchTerm;
}

#pragma mark UI

- (void)initialUISetup {
    self.title = @"Search";
    
    //Tap gesture for overlay
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(dismissKeyboard)];
    [self.overlayView addGestureRecognizer:tapGesture];
}

- (void)dismissKeyboard {
    self.overlayView.hidden = YES;
    [self.searchBar resignFirstResponder];
}

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.searchTerm = [_previousSearchTerms objectAtIndex:indexPath.row];
    [_dataInterface searchForTerm:_searchTerm];
    
    [self performSegueWithIdentifier:@"pushQuestions" sender:self];
}

#pragma mark UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _previousSearchTerms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PreviouslySearchedTermTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"previousSearchCell"
                                                                                 forIndexPath:indexPath];
    cell.searchTerm.text = [_previousSearchTerms objectAtIndex:indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Previously Searched terms";
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.overlayView.hidden = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self dismissKeyboard];
    
    self.searchTerm = searchBar.text;
    [_dataInterface searchForTerm:_searchTerm];
    
    //Push Questions view after making tha network call
    [self performSegueWithIdentifier:@"pushQuestions" sender:self];
}

@end

