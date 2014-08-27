//
//  AnswersTableViewController.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 28/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataInterface.h"

@interface AnswersTableViewController : UITableViewController <DataInterfaceProtocol>

@property (nonatomic, strong) NSString * questionID;

@end
