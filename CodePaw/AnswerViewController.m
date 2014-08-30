//
//  AnswerViewController.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 28/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "AnswerViewController.h"

@interface AnswerViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;

- (IBAction)profileButtonTapped:(id)sender;

@end

@implementation AnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set title
    self.title = [NSString stringWithFormat:@"%@'s answer", _answer.ownerName];
    
    //Populate body
    NSAttributedString * attrbody = [[NSAttributedString alloc] initWithData:[_answer.body
                                                                              dataUsingEncoding:NSUnicodeStringEncoding]
                                                                     options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                          documentAttributes:nil
                                                                       error:nil];
    [self.textView setAttributedText:attrbody];
    
    //Set score
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", _answer.votes];
    
    //profile button
    [self.profileButton setTitle:[NSString stringWithFormat:@"%@'s profile", _answer.ownerName] forState:UIControlStateNormal];
}

- (IBAction)profileButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_answer.ownerLink]];
}

@end
