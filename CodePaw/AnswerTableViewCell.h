//
//  AnswerTableViewCell.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 28/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *answeredBy;
@property (weak, nonatomic) IBOutlet UILabel *answerTitle;

@end
