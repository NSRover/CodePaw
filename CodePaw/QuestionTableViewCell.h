//
//  QuestionTableViewCell.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 26/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *questionTitle;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *answers;
@property (weak, nonatomic) IBOutlet UILabel *ownerName;

@end
