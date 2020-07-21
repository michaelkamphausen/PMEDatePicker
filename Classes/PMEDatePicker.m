//  Created by Michael Kamphausen on 06.11.13.
//  Copyright (c) 2013 Michael Kamphausen. All rights reserved.
//

#import "PMEDatePicker.h"


@interface PMEDatePicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) NSInteger dayComponent;
@property (nonatomic, assign) NSInteger monthComponent;
@property (nonatomic, assign) NSInteger yearComponent;
@property (nonatomic, assign) NSInteger hourComponent;
@property (nonatomic, assign) NSInteger minuteComponent;
@property (nonatomic, assign) NSInteger ampmComponent;
@property (nonatomic, assign) NSInteger numberOfDays;
@property (nonatomic, strong) NSArray* shortMonthNames;
@property (nonatomic, strong) NSArray* ampmSymbols;
@property (nonatomic, strong) NSArray* uniqueSymbols;
@property (nonatomic, strong, readwrite) NSDateFormatter* dateFormatter;
@property (nonatomic, assign, readonly) BOOL is24HourMode;

@end


@implementation PMEDatePicker

static const NSInteger PMEPickerViewMaxNumberOfRows = 16384;
static const NSCalendarUnit PMEPickerViewComponents = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute;

@synthesize date = _date;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.dataSource = self;
    self.delegate = self;
    self.dateFormatTemplate = @"yyyyMMMdjmm";
    self.minimumDate = [NSDate distantPast];
    self.maximumDate = [NSDate distantFuture];
    self.numberOfDays = 31; // default to ensure no divide by zero error when setting self.date before updateNumberOfDays
    self.date = [NSDate date];
    self.textColor = [UIColor blackColor];
    self.textFont = [UIFont systemFontOfSize:20];
    [self updateNumberOfDays];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentLocale) name:NSCurrentLocaleDidChangeNotification object:nil];
}

#pragma mark - methods

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    NSInteger middleBlockIndex = 0;
    if ([self isEndlessComponent:component]) {
        NSInteger numberOfRows = [self realNumberOfRowsInComponent:component];
        middleBlockIndex = ((NSInteger)((PMEPickerViewMaxNumberOfRows / 2) / numberOfRows)) * numberOfRows;
    }
    if(row < 0)
        row = 0;
    [super selectRow:middleBlockIndex + row inComponent:component animated:animated];
}

- (BOOL)isEndlessComponent:(NSInteger)component {
    return (component != self.yearComponent) && (component != self.ampmComponent);
}

- (NSInteger)realSelectedRowInComponent:(NSInteger)component {
    return [self selectedRowInComponent:component] % [self realNumberOfRowsInComponent:component];
}

- (NSInteger)realNumberOfRowsInComponent:(NSInteger)component {
    if (component == self.dayComponent) {
        return self.numberOfDays;
    } else if (component == self.monthComponent) {
        return 12;
    } else if (component == self.yearComponent) {
        NSInteger minimumYear = [[[NSCalendar currentCalendar] components:PMEPickerViewComponents fromDate:self.minimumDate] year];
        NSInteger maximumYear = [[[NSCalendar currentCalendar] components:PMEPickerViewComponents fromDate:self.maximumDate] year];
        return maximumYear - minimumYear + 1;
    } else if (component == self.hourComponent) {
        return self.is24HourMode ? 24 : 12;
    } else if (component == self.minuteComponent) {
        return 60;
    } else if (component == self.ampmComponent) {
        return 2;
    }
    return -1;
}

- (void)updateNumberOfDays
{
    NSDateComponents *currentSelectedDateComponents = [[NSCalendar currentCalendar] components:PMEPickerViewComponents
                                                                                      fromDate:self.date];

    switch (currentSelectedDateComponents.month)
    {
        case 1:
            self.numberOfDays = 31;
            break;
        case 2:
            if(self.yearComponent == NSNotFound ||
               currentSelectedDateComponents.year < 1900 ||
               currentSelectedDateComponents.year > [[[NSCalendar currentCalendar] components:NSYearCalendarUnit
                                                                                                                                                                      fromDate:[NSDate date]] year])
            {
                // Year is disabled, assume leap year so user has access to day 29

                self.numberOfDays = 29;
            } else {
                // Year is enabled, determine whether year is leap year

                self.numberOfDays = [self isLeapYear:currentSelectedDateComponents.year] ? 29 : 28;
            }
            break;
        case 3:
            self.numberOfDays = 31;
            break;
        case 4:
            self.numberOfDays = 30;
            break;
        case 5:
            self.numberOfDays = 31;
            break;
        case 6:
            self.numberOfDays = 30;
            break;
        case 7:
            self.numberOfDays = 31;
            break;
        case 8:
            self.numberOfDays = 31;
            break;
        case 9:
            self.numberOfDays = 30;
            break;
        case 10:
            self.numberOfDays = 31;
            break;
        case 11:
            self.numberOfDays = 30;
            break;
        case 12:
            self.numberOfDays = 31;
            break;
        default:
            self.numberOfDays = 31;
            break;
    }
}

- (NSInteger)rowForYear:(NSInteger)year {
    NSInteger minimumYear = [[[NSCalendar currentCalendar] components:PMEPickerViewComponents fromDate:self.minimumDate] year];
    return year - minimumYear + 1;
}

- (NSInteger)yearForRow:(NSInteger)row {
    NSInteger minimumYear = [[[NSCalendar currentCalendar] components:PMEPickerViewComponents fromDate:self.minimumDate] year];
    return row + minimumYear;
}

- (void)updatePicker {
    [self reloadAllComponents];
    if (_date) {
        self.date = _date;
    }
}

- (void)refreshCurrentLocale {
    self.dateFormatter = nil;
    self.shortMonthNames = nil;
    self.ampmSymbols = nil;
    self.dateFormatTemplate = self.dateFormatTemplate;
    [self didSelectDate];
}

- (BOOL)isLeapYear:(NSInteger)year
{
    if (year % 4 != 0)
        return NO;
    else if (year % 400 == 0)
        return YES;
    else if (year % 100 == 0)
        return NO;
    else
        return YES;
}

#pragma mark - getter & setter

- (NSDate *)date {
    NSDateComponents *components = [NSDateComponents new];
    [components setCalendar:[NSCalendar currentCalendar]];
    if (self.dayComponent != NSNotFound) {
        [components setDay:[self realSelectedRowInComponent:self.dayComponent] + 1];
    }
    if (self.monthComponent != NSNotFound) {
        [components setMonth:[self realSelectedRowInComponent:self.monthComponent] + 1];
    }
    if (self.yearComponent != NSNotFound) {
        [components setYear:[self yearForRow:[self realSelectedRowInComponent:self.yearComponent]]];
    } else {
        // Return a leap year so Feb 29 is accepted as valid when no year is utilized
        [components setYear:2004];
    }
    if (self.hourComponent != NSNotFound) {
        NSInteger offset = !self.is24HourMode && ([self realSelectedRowInComponent:self.ampmComponent] == 1) ? 12 : 0;
        [components setHour:[self realSelectedRowInComponent:self.hourComponent] + offset];
    }
    if (self.minuteComponent != NSNotFound) {
        [components setMinute:[self realSelectedRowInComponent:self.minuteComponent]];
    }
    
    return [components date];
}

- (NSDate *)referenceDate
{
    NSDateComponents *dateComponents = [NSDateComponents new];
    [dateComponents setCalendar:[NSCalendar currentCalendar]];

    if (self.yearComponent == NSNotFound)
    {
        [dateComponents setYear:2004];
    }

    return [dateComponents date];
}

- (void)setSeconds:(NSTimeInterval)seconds
{
    NSDateComponents *dateComponents = [NSDateComponents new];
    [dateComponents setCalendar:[NSCalendar currentCalendar]];

    if (self.yearComponent == NSNotFound)
    {
        [dateComponents setYear:2004];
    }

    [self setDate:[NSDate dateWithTimeInterval:seconds sinceDate:self.referenceDate] animated:YES];
}

- (NSTimeInterval)seconds
{
    return [self.date timeIntervalSinceDate:self.referenceDate];
}

- (void)setDate:(NSDate *)date {
    [self setDate:date animated:NO];
}

- (void)setDate:(NSDate *)date animated:(BOOL)animated {
    _date = date;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:PMEPickerViewComponents fromDate:date];
    if (self.dayComponent != NSNotFound) {
        [self selectRow:[components day] - 1 inComponent:self.dayComponent animated:animated];
    }
    if (self.monthComponent != NSNotFound) {
        [self selectRow:[components month] - 1 inComponent:self.monthComponent animated:animated];
    }
    if (self.yearComponent != NSNotFound) {
        [self selectRow:[self rowForYear:[components year]] - 1 inComponent:self.yearComponent animated:animated];
    }
    if (self.hourComponent != NSNotFound) {
        NSInteger offset = !self.is24HourMode && ([components hour] >= 12) ? 12 : 0;
        [self selectRow:[components hour] - offset inComponent:self.hourComponent animated:animated];
    }
    if (self.minuteComponent != NSNotFound) {
        [self selectRow:[components minute] inComponent:self.minuteComponent animated:animated];
    }
    if (self.ampmComponent != NSNotFound) {
        [self selectRow:([components hour] < 12) ? 0 : 1 inComponent:self.ampmComponent animated:animated];
    }
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    _maximumDate = maximumDate ? maximumDate : [NSDate distantFuture];
    [self updatePicker];
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    _minimumDate = minimumDate ? minimumDate : [NSDate distantPast];
    [self updatePicker];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor ? textColor : [UIColor blackColor];
    [self updatePicker];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont ? textFont : [UIFont systemFontOfSize:20];
    [self updatePicker];
}

- (NSArray *)shortMonthNames {
    if (!_shortMonthNames) {
        _shortMonthNames = [self.dateFormatter shortMonthSymbols];
    }
    return _shortMonthNames;
}

- (NSArray *)ampmSymbols {
    if (!_ampmSymbols) {
        _ampmSymbols = @[[self.dateFormatter AMSymbol], [self.dateFormatter PMSymbol]];
    }
    return _ampmSymbols;
}

- (void)setDateFormatTemplate:(NSString *)dateFormatTemplate {
    _dateFormatTemplate = dateFormatTemplate;
    NSString* dateFormat = [NSDateFormatter dateFormatFromTemplate:dateFormatTemplate options:0 locale:[NSLocale autoupdatingCurrentLocale]];
    
    NSCharacterSet *symbolsToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"yMdHhma"] invertedSet];
    NSString* symbols = [[dateFormat componentsSeparatedByCharactersInSet:symbolsToRemove] componentsJoinedByString:@""];
    NSMutableArray* uniqueSymbols = [NSMutableArray array];
    for (NSUInteger i = 0, maxI = [symbols length]; i < maxI; i++) {
        NSString* character = [symbols substringWithRange:NSMakeRange(i, 1)];
        if (![uniqueSymbols containsObject:character]) {
            [uniqueSymbols addObject:character];
        }
    }
    
    self.dayComponent = [uniqueSymbols indexOfObject:@"d"];
    self.monthComponent = [uniqueSymbols indexOfObject:@"M"];
    self.yearComponent = [uniqueSymbols indexOfObject:@"y"];
    self.hourComponent = [uniqueSymbols indexOfObject:@"H"];
    if (self.hourComponent == NSNotFound) {
        self.hourComponent = [uniqueSymbols indexOfObject:@"h"];
    }
    self.minuteComponent = [uniqueSymbols indexOfObject:@"m"];
    self.ampmComponent = [uniqueSymbols indexOfObject:@"a"];
    self.uniqueSymbols = uniqueSymbols;
    
    [self updatePicker];
}

- (BOOL)is24HourMode {
    return self.ampmComponent == NSNotFound;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:self.dateFormatTemplate options:0 locale:[NSLocale autoupdatingCurrentLocale]]];
        [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    return _dateFormatter;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.uniqueSymbols count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self isEndlessComponent:component] ? PMEPickerViewMaxNumberOfRows : [self realNumberOfRowsInComponent:component];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    row = row % [self realNumberOfRowsInComponent:component];
    if (component == self.dayComponent) {
        return [NSString stringWithFormat:@"%ld", (long)row + 1];
    } else if (component == self.monthComponent) {
        return self.shortMonthNames[row];
    } else if (component == self.yearComponent) {
        return [NSString stringWithFormat:@"%ld", (long)[self yearForRow:row]];
    } else if (component == self.hourComponent) {
        return [NSString stringWithFormat:self.is24HourMode ? @"%02ld" : @"%ld", (!self.is24HourMode && row == 0) ? 12 : (long)row];
    } else if (component == self.minuteComponent) {
        return [NSString stringWithFormat:@"%02ld", (long)row];
    } else if (component == self.ampmComponent) {
        return self.ampmSymbols[row];
    }
    return @"";
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* label = (UILabel*)view;
    if (!label) {
        label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
    }
    label.textColor = self.textColor;
    label.font = self.textFont;
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];

    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == self.dayComponent) {
        return 30.;
    } else if (component == self.monthComponent) {
        return 65.;
    } else if (component == self.yearComponent) {
        return 60.;
    } else if (component == self.hourComponent) {
        return 30.;
    } else if (component == self.minuteComponent) {
        return 30.;
    } else if (component == self.ampmComponent) {
        return 50.;
    }
    return 0.;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    row = row % [self realNumberOfRowsInComponent:component];
    NSDate* date = self.date;
    if ([date timeIntervalSince1970] > [self.maximumDate timeIntervalSince1970]) {
        date = self.maximumDate;
    }
    if ([date timeIntervalSince1970] < [self.minimumDate timeIntervalSince1970]) {
        date = self.minimumDate;
    }
    [self selectRow:row inComponent:component animated:NO];
    [self setDate:date animated:YES];
    [self didSelectDate];
    [self updateNumberOfDays];
    [self updatePicker];
}

- (void)didSelectDate
{
    [self.dateDelegate datePicker:self didSelectDate:self.date];

    if (self.handler)
    {
        self.handler(self.date, self.seconds);
    }
}

@end
