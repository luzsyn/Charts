//
//  CustomViewController.m
//  ChartsDemo-iOS
//
//  Created by 刘志新 on 2020/2/12.
//  Copyright © 2020 dcg. All rights reserved.
//

#import "CustomViewController.h"
#import "ChartsDemo_iOS-Swift.h"

@interface CustomViewController ()<IChartAxisValueFormatter, ChartViewDelegate>

@property (nonatomic, strong) BarChartView *chartView;

/*! data */
@property (nonatomic, copy) NSArray *entryArr;

@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.chartView];
    
    [self setData];
}

- (void)setData
{
    //组装柱状图数据
    //X轴上要显示多少条数据
    NSUInteger xVals_count = 8;
    //对应Y轴上面需要显示的数据
    NSMutableArray *numberArr = [NSMutableArray array];
    NSMutableArray *rateArr = [NSMutableArray array];
    for (NSInteger i = 0; i < xVals_count; i++) {
        BarChartDataEntry *entry1 = [[BarChartDataEntry alloc] initWithX:i y:arc4random_uniform(8)];
        [numberArr addObject:entry1];
        BarChartDataEntry *entry2 = [[BarChartDataEntry alloc] initWithX:i y:arc4random_uniform(100)];
        [rateArr addObject:entry2];
    }
    
    //创建BarChartDataSet对象，其中包含有Y轴数据信息，以及可以设置柱形样式
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithEntries:numberArr label:nil];
    set1.axisDependency = AxisDependencyLeft;
    set1.barBorderWidth = 0;
    set1.drawValuesEnabled = NO;//是否在柱形图上面显示数值
    set1.highlightEnabled = YES;//点击选中柱形图是否有高亮效果
//    [set1 setColors:@[[UIColor colorWithHexString:TeamYellowColor]]];
    [set1 setColor:[UIColor orangeColor]];
    set1.roundedCorners = UIRectCornerAllCorners;
    
    BarChartDataSet *set2 = [[BarChartDataSet alloc] initWithEntries:rateArr label:nil];
    set2.axisDependency = AxisDependencyRight;
    set2.barBorderWidth = 0;
    set2.drawValuesEnabled = YES;
    set2.valueLabelAngle = 90;
    set2.highlightEnabled = NO;
//    [set2 setColors:@[[UIColor colorWithHexString:TeamGreenColor]]];
    [set2 setColor:[UIColor purpleColor]];
    set2.roundedCorners = UIRectCornerAllCorners;
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @"%";
    [set2 setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [set2 setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.f]];
    [set2 setValueTextColor:UIColor.purpleColor];
    
    //将BarChartDataSet对象放入数组中
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    [dataSets addObject:set2];
    //创建BarChartData对象, 此对象就是barChartView需要最终数据对象
    BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
    //设置宽度   柱形之间的间隙占整个柱形(柱形+间隙)的比例
    // (barSpace + barWidth) * 系列数 + groupSpace = 1.00 -> interval per "group"
    CGFloat barWidth = 0.1;
    CGFloat barSpace = 0.1;
    CGFloat groupSpace = 0.6;
    if (xVals_count < 5) {
        barWidth = 0.06 * xVals_count / 2.0;
        barSpace = 0.06 * xVals_count / 2.0;
        groupSpace = 1.0 - (barWidth + barWidth) * 2;
    }
    
    [data setBarWidth:barWidth];
    [data groupBarsFromX:0 groupSpace:groupSpace barSpace:barSpace];
    
    //设置人数最大值，便于左右坐标轴对齐
    if ((NSInteger)set1.yMax % 5 != 0) {
        CGFloat max = ceil(set1.yMax);
        max = (5 - (NSInteger)max % 5) + max;
        self.chartView.leftAxis.axisMaximum = max;
    } else if (set1.yMax == 0) {
        self.chartView.leftAxis.axisMaximum = 5;
    } else {
        self.chartView.leftAxis.axisMaximum = set1.yMax;
    }
    // restrict the x-axis range
    self.chartView.xAxis.axisMinimum = 0;
    self.chartView.xAxis.axisMaximum = 0 + [data groupWidthWithGroupSpace:groupSpace barSpace:barSpace] * xVals_count;
    
    self.chartView.data = data;
    //设置显示多少个
    if (xVals_count > 5) {
        [self.chartView setVisibleXRangeMaximum:5];
    } else {
        [self.chartView fitScreen];
    }
    [self.chartView.data notifyDataChanged];
    [self.chartView notifyDataSetChanged];
}


- (BarChartView *)chartView
{
    if (!_chartView) {
        
        BarChartView *barChartView = [[BarChartView alloc] init];
        barChartView.frame = CGRectMake(15, [UIApplication sharedApplication].statusBarFrame.size.height + 44 + 20, [UIScreen mainScreen].bounds.size.width - 15, 240);
        barChartView.backgroundColor = [UIColor clearColor];
        barChartView.delegate = self;
        
        barChartView.noDataText = @"暂无数据";
        barChartView.drawValueAboveBarEnabled = YES;
        barChartView.drawBarShadowEnabled = NO;
        barChartView.scaleXEnabled = NO;
        barChartView.scaleYEnabled = NO;
        barChartView.doubleTapToZoomEnabled = NO;
        barChartView.chartDescription.enabled = NO;
        barChartView.pinchZoomEnabled = NO;
        barChartView.dragYEnabled = NO;
        
        ChartXAxis *xAxis = barChartView.xAxis;
        xAxis.valueFormatter = self;
        xAxis.axisLineWidth = 0.5;
        xAxis.axisLineDashLengths = @[@3.0f, @3.0f];
//        xAxis.axisLineColor = [UIColor colorWithHexString:@"#EEEEEE"];
        xAxis.labelPosition = XAxisLabelPositionBottom;
        //绘制网格线
        xAxis.drawGridLinesEnabled = NO;
        xAxis.gridLineDashLengths = @[@3.0f, @3.0f];
//        xAxis.gridColor = [UIColor colorWithHexString:@"#EEEEEE"];
        //开启抗锯齿
        xAxis.gridAntialiasEnabled = YES;
        //label文字颜色
//        xAxis.labelTextColor = [UIColor thirdClassGray];
//        xAxis.labelFont = [UIFont systemFontOfRatioSize:12];
        xAxis.yOffset = 10;
        xAxis.granularity = 1.f;
        xAxis.centerAxisLabelsEnabled = YES;
        //        xAxis.wordWrapEnabled = YES;
        xAxis.drawLabelBackgroundEnabled = YES;
        xAxis.labelBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        
        //左边Y轴
        ChartYAxis *leftAxis = barChartView.leftAxis;
        leftAxis.axisLineWidth = 0.5;
//        leftAxis.axisLineColor = [UIColor colorWithHexString:@"#F2F2F2"];
        leftAxis.axisMinimum = 0;
        //设置虚线样式的网格线
        leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];
//        leftAxis.gridColor = [UIColor colorWithHexString:@"#EEEEEE"];
        //开启抗锯齿
        leftAxis.gridAntialiasEnabled = YES;
        //label文字颜色
//        leftAxis.labelTextColor = [UIColor thirdClassGray];
//        leftAxis.labelFont = [UIFont systemFontOfRatioSize:12];
        //y轴顶部封顶线
        //        leftAxis.forceLabelsEnabled = YES;
        leftAxis.granularityEnabled = YES;
        leftAxis.granularity = 1;
        leftAxis.labelCount = 6;
        leftAxis.forceLabelsEnabled = YES;
        
        //右边Y轴
        NSNumberFormatter *rightAxisFormatter = [[NSNumberFormatter alloc] init];
        rightAxisFormatter.minimumFractionDigits = 0;
        rightAxisFormatter.maximumFractionDigits = 1;
        rightAxisFormatter.positiveSuffix = @"%";
        //        rightAxisFormatter.numberStyle = NSNumberFormatterPercentStyle;
        
        ChartYAxis *rightAxis = barChartView.rightAxis;
        rightAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:rightAxisFormatter];
        rightAxis.axisLineWidth = 0;//Y轴线宽
//        rightAxis.axisLineColor = [UIColor colorWithHexString:@"#F2F2F2"];
        rightAxis.drawGridLinesEnabled = NO;
        rightAxis.axisMinimum = 0;
        rightAxis.axisMaximum = 100;
//        rightAxis.labelTextColor = [UIColor thirdClassGray];//label文字颜色
//        rightAxis.labelFont = [UIFont systemFontOfRatioSize:12];
        rightAxis.granularityEnabled = YES;
        rightAxis.granularity = 1;
        rightAxis.drawLabelsEnabled = NO;
        //y轴顶部封顶线
        barChartView.rightAxis.enabled = YES;
        
        //不显示图例说明
        barChartView.legend.enabled = NO;
        
        barChartView.extraBottomOffset = 8;
        
        _chartView = barChartView;
    }
    return _chartView;
}

#pragma mark - ChartViewXAxisLabelDataSource

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    if (value < 0) return @"";
    return @[@"前端组", @"App组", @"说呢过吃组", @"运维组", @"aaa组", @"bbbbbb组", @"111222333", @"UI设计组", @"产品组", @"运营组"][(int)value];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected：%@", @(highlight.dataSetIndex));
}


@end
