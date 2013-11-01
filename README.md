CCSlideSearchView
=================

A convenient vertical search bar as a replacement to manual typing for traversing large amounts of data.

It lets users swipe down a vertical list of characters (similar to the Contacts app), and then lets the user swipe left to select multiple letters at a time

Requirements
--------
• iOS 4.3 and higher
• ARC

Implementation
-------
• Add the `CCSlideSearchView.{h,m}` files to your XCode project.
• Include `#import "CCSlideSearchView.h"` to the header of a file using the view.
• Initialize with `[[CCSlideSearchView alloc] initWithFrame:(CGRect)frame]`
• Then set the `CCSlideSearchViewDelegate` (recommended), and add to your superview

Delegation
-------
`- (void)slideSearchDidBegin:(CCSlideSearchView *)searchView;`

Called when user first interacts with the view


`- (void)slideSearch:(CCSlideSearchView *)searchView didHoverLetter:(NSString *)letter atIndex:(NSInteger)index withSearchTerm:(NSString *)term;`

Called when the user is hovering vertically over the list of letters


`- (void)slideSearch:(CCSlideSearchView *)searchView didConfirmLetter:(NSString *)letter atIndex:(NSInteger)index withSearchTerm:(NSString *)term;`

Called when the user swipes left to select a letter and add it to the current search term


`- (void)slideSearch:(CCSlideSearchView *)searchView didFinishSearchWithTerm:(NSString *)term;`

Called when the user has stopped interacting with the view, and returns the search term chosen by the user


Customization
-------
**Setting character limits**
Limit how many characters the user can select in a given search
Set the `characterLimit` (int) property of the view

**Showing the current search term**
By default, it shows the term being searched
To disable, set property `highlightsWhileSearching = FALSE`

**Changing UI and color**
Edit the background color and the text colors
Change the `highlighter.png` image to change background image
Text color and attributes are defined by macros in the .m file

Author
-------
Tom Bachant
(sobrioapp.com)
(coincidentalcode.com)

License
-------
**MIT License**

Copyright (c) 2013 Thomas Bachant

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
