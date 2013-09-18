//
//  CCViewController.m
//  SlideSearchExample
//
//  Created by Tom Bachant on 8/12/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import "CCViewController.h"

@interface CCViewController ()

@end

@implementation CCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /**
     Let's load some dummy data!
     
     This is a big mess of words that we may want to search through quickly and easily
     
     Credit to OpenMedSpel for this list of words. The README is available in this project
     */
    
    NSString* path = [[NSBundle mainBundle] pathForResource: @"medical" ofType: @"txt"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSString *rawString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    rawString = [[rawString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    NSArray *separatedStrings = [rawString componentsSeparatedByString:@" "];

    if (_contentArray == nil) {
        _contentArray = [[NSArray alloc] initWithArray:separatedStrings];
    }
    
    self.searchTerm = @"";
    
    /**
     Now that we've got a ton of strings set up, let's add the slide search view to look through them easily
     */
    CGFloat searchViewWidth = 36.0f;; // How wide the search view is gonna be... let's keep it reasonable
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    CCSlideSearchView *searchView = [[CCSlideSearchView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - searchViewWidth, 0, searchViewWidth, CGRectGetHeight(screenFrame) - CGRectGetHeight(self.navigationController.navigationBar.frame) - 20)];
    searchView.delegate = self;
    searchView.characterLimit = 8; // If set to 1, horizontal movement would be disabled
    [self.view addSubview:searchView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
                                   
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_contentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSString *cellTitle = [_contentArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = cellTitle;
    
	return cell;
}

#pragma mark - Actions

- (void)cancelSearch {
    self.searchTerm = @"";
    
    self.title = @"Slide Search Example";
    self.navigationItem.rightBarButtonItem = nil;
    
    [theTableView reloadData];
}

- (void)didSearchNewLetter:(NSString *)letter {
    self.searchTerm = [NSString stringWithFormat:@"%@%@", self.searchTerm, letter];
    self.title = self.searchTerm;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelSearch)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

#pragma mark - CCSlideSearchDelegate

- (void)slideSearchDidBegin:(CCSlideSearchView *)searchView {
    
}

- (void)slideSearch:(CCSlideSearchView *)searchView didHoverLetter:(NSString *)letter atIndex:(NSInteger)index withSearchTerm:(NSString *)term {
    
    NSString *termToSearch = [NSString stringWithFormat:@"%@%@", term, letter];
    
    int indexPathRowToScroll = -1;;
    
    for (int i = 0; i < [_contentArray count]; i++) {
         
         if ([[[_contentArray objectAtIndex:i] lowercaseString] hasPrefix:[termToSearch lowercaseString]]) {
             indexPathRowToScroll = i;
             break;
         }
        
    }
    
    [theTableView reloadData];
    
    if (indexPathRowToScroll >= 0) {
        [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPathRowToScroll inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)slideSearch:(CCSlideSearchView *)searchView didConfirmLetter:(NSString *)letter atIndex:(NSInteger)index withSearchTerm:(NSString *)term {
    
    [self didSearchNewLetter:letter];
    
    [theTableView reloadData];
    
}

- (void)slideSearch:(CCSlideSearchView *)searchView didFinishSearchWithTerm:(NSString *)term {
    [self cancelSearch];
}

@end
