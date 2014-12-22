PMEDatePicker
=========
DatePicker with configurable date components.

* compared to UIDatePicker you decide if you want to display day, month, year, hour, minute and am/pm in any combination
* supported date symbols are yyyy, MMM, d, HH, h, mm, j, a
* order of the date components, month and AM/PM symbols is defined by the current NSLocale
* availability of AM / PM is automatically defined by NSLocale except you explicitely set it
* supports minimumDate and maximumDate
* UIPickerView subclass

## Installation
Install via cocoapods by adding this to your Podfile:

	pod "PMEDatePicker"

## Usage
Import header file:

	#import "PMEDatePicker.h"
	
Initialize the PMEDatePicker in code or in your Storyboard or XIB file like an UIPickerView as it is an UIPickerView subclass.

You should not set the `delegate` or `dataSource` property as a PMEDatePicker object is it's own `delegate` and `dataSource`. Use `dateDelegate` instead:

	self.datePicker.dateDelegate = self;
	
To define the available date components, use the `dateFormatTemplate` property with date symbols:

	self.datePicker.dateFormatTemplate = @"yyyyMMM";

Supported date symbols are:

* `yyyy`: full year
* `MMM`: short month name
* `d`: day (single digit)
* `HH`: hours, 24 hour format (two digits)
* `h`: hours, 12 hour format (one digit)
* `mm`: minutes (two digits)
* `j`: expands to HH, h, mm, a depending on locale
* `a`: AM/PM symbol

Default is `yyyyMMMdjmm`, which means that full year, short month names, day, minutes and hours in 24 hour or 12 hour format with AM/PM symbols depending on the locale are displayed.

The order of date components is determined by the current NSLocale.

It is possible to set a `minimumDate` and `maximumDate`. The currently selected date can be retrieved and set via `date` property or via `setDate:animated:` method.