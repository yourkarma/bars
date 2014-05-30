# Bars

iOS library for displaying bar graphs

![Bars gif](https://raw.githubusercontent.com/yourkarma/bars/master/Example/bars.gif)

## Installation

Bars is available through [CocoaPods](http://cocoapods.org), to install it simply add the following line to your Podfile:

    pod "Bars"

Want to try first? Simple:

    pod try Bars

## Usage

BARView is used much the same as UITableView or UICollectionView. Add it to your view hierarchy
and set a data source that implements the required methods 
of the [`BARViewDataSource`](https://github.com/yourkarma/bars/blob/master/Classes/BARView.h#L54) 
formal protocol. 

Call `reloadData` every time your data changes.

## Customize

Appearance can be customized using the `barColor`, `selectionIndicatorColor`, `gridColor` and
`showsSelectionIndicator` properties.

## Inspiration

This project was inspired by the graphs in [Ins & Outs](http://insandoutsapp.com/).

## License

Bars is available under the MIT license. See the [LICENSE](https://github.com/yourkarma/bars/blob/master/LICENSE) file for more info.
