//
//  CCViewController.h
//  SlideSearchExample
//
//  Created by Tom Bachant on 8/12/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "CCSlideSearchView.h"

@interface CCViewController : UIViewController <UITableViewDataSource, CCSlideSearchDelegate> {
    IBOutlet UITableView *theTableView;
    
}

@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSArray *contentArray;

- (void)cancelSearch;
- (void)didSearchNewLetter:(NSString *)letter;

@end
