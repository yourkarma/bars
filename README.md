# Bars

iOS library for displaying bar graphs

![Bars gif](https://www.dropbox.com/s/j83quxeh4wopl0d/bars.gif)

## Installation

Bars is available through [CocoaPods](http://cocoapods.org), to install it simply add the following line to your Podfile:

    pod "Bars"

Want to try first? Simple:

    pod try Bars

## Usage

BARView is used much the same as UITableView or UICollectionView. Add it to your view hierarchy
and set a data source that implement the required methods 
of the [`BARViewDataSource`](https://github.com/yourkarma/bars/blob/master/Classes/BARView.h#L54) 
formal protocol. 

Call `reloadData` every time your data changes.

## Customize

Appearance can be customized using the `barColor`, `selectionIndicatorColor`, `gridColor` and
`showsSelectionIndicator` properties.

## License

Bars is available under the MIT license. See the LICENSE file for more info.
