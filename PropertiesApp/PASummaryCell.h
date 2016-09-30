//
//  PASummaryCell.h
//  PropertiesApp
//
//  Created by Mark Smith on 27/09/2016.
//  Copyright © 2016 ___MARKSMITH___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PASummaryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *lowestPrice;
@property (strong, nonatomic) NSString *url;
@property (nonatomic, strong) NSString *thumbnailName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
