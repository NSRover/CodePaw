//
//  SearchHistory.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 22/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SearchHistory : NSManagedObject

@property (nonatomic, retain) NSString * searchTerm;
@property (nonatomic, retain) NSString * dataLocation;

@end
