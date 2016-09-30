//
//  PAImageViewController.m
//  PropertiesApp
//
//  Created by Mark Smith on 28/09/2016.
//  Copyright © 2016 ___MARKSMITH___. All rights reserved.
//

#import "PAImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PAImageViewController ()

@end

@implementation PAImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.indexLabel.text = [NSString stringWithFormat:@"%ld", (long)self.index];
    
    // load the image - a cached image will be returned if available
    /*[self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURL] placeholderImage:[UIImage imageNamed:@"Placeholder"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        //[cell.activityIndicator stopAnimating];            
    }];*/
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadImage:(NSString*)imageURL {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"Placeholder"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.imageViewLoaded = TRUE;
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
