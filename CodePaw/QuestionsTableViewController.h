//
//  QuestionsTableViewController.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 26/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataInterface.h"

@interface QuestionsTableViewController : UITableViewController <DataInterfaceProtocol>

@property (nonatomic, strong) NSString * searchTerm;

@end
