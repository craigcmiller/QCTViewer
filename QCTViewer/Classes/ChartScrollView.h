//
//  ChartScrollView.h
//  iQct
//
//  Created by craig on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface ChartScrollView : UIScrollView {

}

- (id)initWithFrame:(CGRect)frame;

@property (readonly, nonatomic, getter=visibleContentRect) CGRect visibleContentRect;

@end
