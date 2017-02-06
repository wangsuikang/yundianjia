//
//  DistributionStatViewController.h
//  Shops-iPhone
//
//  Created by xxy on 15/8/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChartDelegate.h"
#import "PNChart.h"

@interface DistributionStatViewController : UIViewController

@property (nonatomic) PNLineChart * lineChart;

@property (nonatomic) PNCircleChart * circleChart;

@end
