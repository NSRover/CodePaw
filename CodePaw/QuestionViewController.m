//
//  QuestionViewController.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 26/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "QuestionViewController.h"

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
}

#pragma mark Webview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)answersButtonTapped:(id)sender {
}

- (IBAction)profileButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_question.ownerLink]];
}

@end
