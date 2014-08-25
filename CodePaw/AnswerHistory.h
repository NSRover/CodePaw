//
//  AnswerHistory.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 25/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AnswerHistory : NSManagedObject

@property (nonatomic, retain) NSString * questionID;
@property (nonatomic, retain) NSString * dataLocation;

@end
