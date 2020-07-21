//  Created by Michael Kamphausen on 06.11.13.
//  Copyright (c) 2013 Michael Kamphausen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMEDatePicker;

typedef void (^PMEDatePickerHandler)(NSDate *date, NSTimeInterval seconds);

@protocol PMEDatePickerDelegate;

@interface PMEDatePicker : UIPickerView

@property (nonatomic, strong) NSDate* date;
@property (nonatomic) NSTimeInterval seconds;
@property (readonly, nonatomic) NSDate *referenceDate;
@property (nonatomic, strong) NSDate* maximumDate;
@property (nonatomic, strong) NSDate* minimumDate;
@property (nonatomic, strong, readonly) NSDateFormatter* dateFormatter;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIFont *textFont;
//! Supported date symbols are yyyy, MMM, d, HH, h, mm, j, a. Default is 'yyyyMMMdjmm'. Order is determined by locale.
@property (nonatomic, copy) NSString* dateFormatTemplate;
//! Use this delegate instead of inherited delegate and dataSource properties
@property (nonatomic, weak) IBOutlet id<PMEDatePickerDelegate> dateDelegate;
@property (strong) PMEDatePickerHandler handler;

- (void)setDate:(NSDate*)date animated:(BOOL)animated;

@end

@protocol PMEDatePickerDelegate <NSObject>

- (void)datePicker:(PMEDatePicker*)datePicker didSelectDate:(NSDate*)date;

@end
