//
//  PSNavigationSidebar.h
//  NavigationSidebar
//
//  Created by Sergey Pronin on 02/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSNavigationSidebar : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tableView;
    UIView *contentView;
    float startx;
    
    UITapGestureRecognizer *tapRecognizer;
    NSArray *viewControllers;
}

//singleton
+(PSNavigationSidebar *)sharedNavigationSideBar;

//methods to show or hide sidebar
-(void)showNavigationSideBar;
-(void)hideNavigationSideBar;

//controllers in sidebar (from top to bottom)
//should have "title" property, which will be shown in sidebar's tableview
@property (nonatomic, retain) NSArray *viewControllers;

@end
