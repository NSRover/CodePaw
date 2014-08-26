//
//  QuestionViewController.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 26/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionBrief.h"

@interface QuestionViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) QuestionBrief * question;

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UIWebView *bodyWebView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *answersButton;

- (IBAction)answersButtonTapped:(id)sender;
- (IBAction)profileButtonTapped:(id)sender;

@end
