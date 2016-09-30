//
//  DetailViewController.m
//  PropertiesApp
//
//  Created by Mark Smith on 26/09/2016.
//  Copyright © 2016 ___MARKSMITH___. All rights reserved.
//

#import "DetailViewController.h"
#import "PARESTManager.h"
#import "PAImageViewController.h"
#import "PropertyDetails.h"
#import "Image.h"


@interface DetailViewController () <UICollectionViewDelegateFlowLayout, UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UIView *slideShowContainer;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *country;
@property (weak, nonatomic) IBOutlet UITextView *propertyDescription;
@property (weak, nonatomic) IBOutlet UITextView *directions;
@property (weak, nonatomic) IBOutlet UILabel *directionsHeading;

@property (nonatomic, strong) NSString *propertyID;
@property (weak, nonatomic) IBOutlet UIView *defaultOverviewPlaceholder;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *descriptionActivityIndicator;

@property (strong, nonatomic) UIPageViewController *imagePageController;

@property (assign) NSInteger curIndex;
@property (assign) NSInteger nextIndex;
@property (nonatomic, strong) NSMutableArray *imageURLs;
@property (nonatomic, strong) NSMutableArray *imageViewControllers;
@property (assign) NSInteger imageViewControllerCount;

/*
 • the property name
• the address
• address1 • address2 • city
• country
• the property description
• the property directions
• at least one of the images from the property
 */

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setPropertySummaryMO:(id)propertySummaryMO {
    if (_propertySummaryMO != propertySummaryMO) {
        _propertySummaryMO = propertySummaryMO;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    

    if (self.propertySummaryMO) {
        
        // Update the user interface with whatever data is available from the master view. Other fields will be populated once the property details have been retrieved from the server.
        self.name.text = [[self.propertySummaryMO valueForKey:@"name"] description];

        self.propertyID = [[self.propertySummaryMO valueForKey:@"id"] description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configureView];
    
    // hack to get round iPad UITextView not responding to IB setting
    self.propertyDescription.editable = YES;
    self.propertyDescription.font = [UIFont systemFontOfSize:18.];
    self.propertyDescription.editable = NO;
    self.directions.editable = YES;
    self.directions.font = [UIFont systemFontOfSize:18.];
    self.directions.editable = NO;
    
    self.propertyDescription.hidden = TRUE;
    self.directionsHeading.hidden = TRUE;
    self.directions.hidden = TRUE;
    
    if (!self.propertyID) {
        
        // we have most likely started in split screen mode. in split screen mode, detail view controller appears without any master cell being selected yet, i.e. iPad, or iPhone 6s Plus in landscape mode.
        //self.view.hidden = TRUE;
        //[self.descriptionActivityIndicator stopAnimating];
        self.defaultOverviewPlaceholder.hidden = FALSE;
        return;
    }
    
    // set up the image slide show
    
    self.imagePageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [[self.imagePageController view] setFrame:self.slideShowContainer.bounds];
    
    self.imageViewControllers = [NSMutableArray array];
    self.imageViewControllerCount = 1;
    PAImageViewController *imageVC = [self viewControllerAtIndex:0];
    [self.imageViewControllers addObject:imageVC];
    
    self.curIndex = 0;
    [self.imagePageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self.slideShowContainer addSubview:[self.imagePageController view]];
    [self.imagePageController didMoveToParentViewController:self];
    self.imagePageController.dataSource = self;
    self.imagePageController.delegate = self;
    
    
    [[PARESTManager sharedInstance] getPropertyDetailsWithPropertyID:self.propertyID success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        PropertyDetails *propertyDetailsMO =  mappingResult.array[0];
        
        // update the ui with property details
        self.address.text = [NSString stringWithFormat:@"%@, %@",[[propertyDetailsMO valueForKey:@"address1"] description], [[propertyDetailsMO valueForKey:@"address1"] description]];
        self.propertyDescription.text = [[propertyDetailsMO valueForKey:@"propertyDescription"] description];
        self.directions.text = [[propertyDetailsMO valueForKey:@"directions"] description];
        
        self.propertyDescription.hidden = FALSE;
        self.directionsHeading.hidden = FALSE;
        self.directions.hidden = FALSE;
        
        // determine the image URLs and how many
        NSArray *imagesMOArr = [propertyDetailsMO valueForKey:@"images"];
        self.imageURLs = [NSMutableArray array];
        for (int i = 0; i < imagesMOArr.count; i++) {
            Image *imageMO = imagesMOArr[i];
            NSString *URLStr = [NSString stringWithFormat:@"%@%@", [[imageMO valueForKey:@"prefix"] description], [[imageMO valueForKey:@"suffix"] description]];
            [self.imageURLs addObject:URLStr];
        }
        self.imageViewControllerCount = self.imageURLs.count;

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        //
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PAImageViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    for (PAImageViewController *imageVC in self.imageViewControllers) {
        if (imageVC.index == index) {
            if (!imageVC.imageViewLoaded) {
                [imageVC loadImage:self.imageURLs[index]];
            }
            return imageVC;
        }
    }
    
    PAImageViewController *imageVC = [[PAImageViewController alloc] initWithNibName:@"PAImageViewController" bundle:nil];
    imageVC.index = index;
    [imageVC loadImage:self.imageURLs[index]];
    
    [self.imageViewControllers addObject:imageVC];
    return imageVC;
}

#pragma mark - UIPageViewControllerDelegate methods

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    
    PAImageViewController* imageVC = [pendingViewControllers firstObject];
    self.nextIndex = [self.imageViewControllers indexOfObject:imageVC];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    if(completed){
        
        self.curIndex = self.nextIndex;
        
    }
    
    self.nextIndex = 0;
    
}


#pragma mark - UIPageViewControllerDataSource methods

// The number of items reflected in the page indicator. NOTE: I am not implementing this because I have a problem with the page view indicator and don't want it visible
/*- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(6_0) {
    return self.imageViewControllerCount;
}*/

// The selected item reflected in the page indicator. NOTE: I am not implementing this because I have a problem with the page view indicator and don't want it visible
/*- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(6_0) {
    return (NSInteger)self.curIndex;
    //return 0;
}*/

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = [(PAImageViewController *)viewController index];
    if (index == 0) {
        return nil;
    }
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = [(PAImageViewController *)viewController index];
    index++;
    
    if (index == self.imageViewControllerCount) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

@end
