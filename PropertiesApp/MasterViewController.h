//
//  MasterViewController.h
//  PropertiesApp
//
//  Created by Mark Smith on 26/09/2016.
//  Copyright © 2016 ___MARKSMITH___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

