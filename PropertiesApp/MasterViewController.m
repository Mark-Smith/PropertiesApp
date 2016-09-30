//
//  MasterViewController.m
//  PropertiesApp
//
//  Created by Mark Smith on 26/09/2016.
//  Copyright © 2016 ___MARKSMITH___. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "PACoreDataHelper.h"
#import "PARESTManager.h"
#import "UIView+Toast.h"
#import "PASummaryCell.h"
#import "Image.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DetailViewController.h"


#define kCityID @"1530"


@interface MasterViewController () <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
// see https://www.raywenderlich.com/999/core-data-tutorial-for-ios-how-to-use-nsfetchedresultscontroller

@end


@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // clear the cache. why?
    [[PACoreDataHelper sharedInstance] clearManagedObjectContextCacheForEntity:@"PropertySummary" withId:-1];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.navigationItem.leftBarButtonItem = nil;
    
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    //self.tableView.estimatedRowHeight = 44.0; // set to whatever your "average" cell height is
    
    // get property summaries
    [[PARESTManager sharedInstance] getPropertySummariesWithCityID:kCityID success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self.tableView reloadData];
        
        [self.navigationController.view makeToast:@"Property Summaries Loaded"];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.navigationController.view makeToast:@"Failed to Load Property Summaries"];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// http://stackoverflow.com/a/25896529
- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]]
        && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] propertySummaryMO] == nil)) {
        
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
        
    } else {
        
        return NO;
        
    }
}


- (IBAction)refresh:(id)sender {
    
    // Reload the data
    [[PARESTManager sharedInstance] getPropertySummariesWithCityID:kCityID success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.navigationController.view makeToast:@"Properties Summaries Loaded"];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.navigationController.view makeToast:@"Failed to Load Properties Summaries"];
    }];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    if ([[segue identifier] isEqualToString:@"ShowDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *propertySummaryMO = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        // pass in the property summary managed object - so that relevant fields in the detail screen can be populated immediately - rather than waiting for the summary object to be retieved from the server
        [controller setPropertySummaryMO:propertySummaryMO];
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PASummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SummaryCell" forIndexPath:indexPath];
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self configureCell:cell withObject:object forIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(PASummaryCell *)cell withObject:(NSManagedObject *)object forIndexPath:(NSIndexPath*)indexPath {
    
    cell.name.text = [[object valueForKey:@"name"] description];
    cell.type.text = [[object valueForKey:@"type"] description];
    cell.rating.text = [[object valueForKey:@"overallRating"] stringValue];
    cell.lowestPrice.text = @"undefined"; // data for this seems not to be available
    
    // construct image url for first image
    NSArray *images = [object valueForKey:@"images"];
    if (images.count) {
        
        Image *image = images[0];
        NSString *URLStr = [NSString stringWithFormat:@"%@%@%@", [[image valueForKey:@"prefix"] description], @"_s", [[image valueForKey:@"suffix"] description]];
        
        [cell.activityIndicator startAnimating];
        
        // Load the image from the server and display it
        // see https://github.com/rs/SDWebImage
        [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:URLStr] placeholderImage:nil options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

            [cell.activityIndicator stopAnimating];
        }];
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"overallRating" ascending:NO];

    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withObject:anObject forIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - UIScrollViewDelegate methods

/*- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [[PARESTManager sharedInstance] getPropertySummariesWithCityID:kCityID success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.navigationController.view makeToast:@"Failed to Property Summaries"];
        }];
    }
}*/

@end
