//
//  SearchViewController.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 26/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "SearchViewController.h"

#import "DataInterface.h"
#import "QuestionBrief.h"
#import "Answer.h"
#import "PreviouslySearchedTermTableViewCell.h"

#import "QuestionsTableViewController.h"

@interface SearchViewController ()

@property (nonatomic, strong) DataInterface * dataInterface;
@property (nonatomic, strong) NSArray * previousSearchTerms;
@property (nonatomic, strong) NSString * searchTerm;
@end

@implementation SearchViewController

#pragma mark Navigation

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Update UI
    [self initialUISetup];
    
    self.dataInterface = [DataInterface sharedInterface];
    _dataInterface.delegate = self;
    
    self.previousSearchTerms = [_dataInterface previouslySearchedTerms];
    
    //    [[DataInterface sharedInterface] searchForTerm:@"SpriteKit"];
    //    [[DataInterface sharedInterface] getAnswersForQuestionID:@"22734157"];
    
    //    NSLog(@"Previously searched terms");
    //    for (NSString * searchTerm in [_dataInterface previouslySearchedTerms]) {
    //        NSLog(@"    %@", searchTerm);
    //    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [_dataInterface searchForTerm:_searchTerm];
    
    QuestionsTableViewController * questionsViewController = (QuestionsTableViewController *)[segue destinationViewController];
    questionsViewController.searchTerm = _searchTerm;
}

#pragma mark UI

- (void)initialUISetup {
    self.title = @"Search";
    //        [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark Data protocol

- (void)dataAvailableForType:(TaskType)type {
    QuestionBrief * question = [_dataInterface.searchResults objectAtIndex:0];
    NSLog(@"Title : %@", question.title);
    //    NSLog(@"Body : %@", question.body);
    
    //    Answer * answer = [_dataInterface.answers objectAtIndex:0];
    //    NSLog(@"Title: %@", answer.title);
    //    NSLog(@"Body: %@", answer.body);
}

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.searchTerm = [_previousSearchTerms objectAtIndex:indexPath.row];
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

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;                      // return NO to not become first responder
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;                     // called when text starts editing
//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;                        // return NO to not resign first responder
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;                       // called when text ends editing
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0); // called before text changes
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;                     // called when keyboard search button pressed
//- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar;                   // called when bookmark button pressed
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;                     // called when cancel button pressed
//- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2); // called when search results button pressed
//
//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0);

@end

