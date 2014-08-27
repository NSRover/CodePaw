//
//  QuestionViewController.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 26/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "QuestionViewController.h"
#import "DataInterface.h"
#import "AnswersTableViewController.h"

@interface QuestionViewController ()

@end

@implementation QuestionViewController

#pragma mark Navigation

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@'s question", _question.ownerName];
    self.titleTextView.text = _question.title;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", _question.votes];
    [self.profileButton setTitle:[NSString stringWithFormat:@"%@'s profile", _question.ownerName] forState:UIControlStateNormal];

    if (_question.numberOfAnswers > 0) {
        self.answersButton.title = [NSString stringWithFormat:@"Answers(%d)", _question.numberOfAnswers];
    }
    else {
        self.answersButton.title = @"Unanswered";
    }
    
    [self.bodyWebView loadHTMLString:_question.body baseURL:nil];
    
    //Make network call to get answers
    [[DataInterface sharedInterface] getAnswersForQuestionID:_question.questionID];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AnswersTableViewController * answersViewController = (AnswersTableViewController *)[segue destinationViewController];
    answersViewController.questionID = _question.questionID;
}


#pragma mark Webview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

#pragma mark IBOutlets

- (IBAction)answersButtonTapped:(id)sender {
    if (_question.numberOfAnswers > 0) {
        [self performSegueWithIdentifier:@"pushAnswers" sender:nil];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"No Answers"
                                    message:@"This question has not been answered yet"
                                   delegate:nil
                          cancelButtonTitle:@":("
                          otherButtonTitles:nil, nil] show];
    }
}

- (IBAction)profileButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_question.ownerLink]];
}

@end
