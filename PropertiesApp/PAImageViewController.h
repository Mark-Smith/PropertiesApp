//
//  PAImageViewController.h
//  PropertiesApp
//
//  Created by Mark Smith on 28/09/2016.
//  Copyright © 2016 ___MARKSMITH___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAImageViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSString *imageURL;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (assign) BOOL imageViewLoaded;

- (void)loadImage:(NSString*)imageURL;

@end
