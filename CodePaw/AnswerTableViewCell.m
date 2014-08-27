//
//  AnswerTableViewCell.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 28/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "AnswerTableViewCell.h"

@implementation AnswerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
