//
//  QYinsertIntoVc.m
//  01-数据持久化作业
//
//  Created by qingyun on 16/6/20.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "QYinsertIntoVc.h"
#import "QYDataBaseTool.h"
#import "QYstudent.h"

@interface QYinsertIntoVc ()
@property (weak, nonatomic) IBOutlet UITextField *stuIdTf;
@property (weak, nonatomic) IBOutlet UITextField *nameTf;
@property (weak, nonatomic) IBOutlet UITextField *ageTf;

@end

@implementation QYinsertIntoVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)insertAction:(id)sender {
    //参数设置
    NSDictionary *pars=@{@"stu_id":_stuIdTf.text,@"name":_nameTf.text,@"age":_ageTf.text};
    //执行sql语句
    __weak QYinsertIntoVc *vc=self;
    [QYDataBaseTool updateStatementsSql:Inserinto withParsmeters:pars block:^(BOOL isOk, NSString *errorMsg) {
        if (isOk) {
            //回调当前参数
            if (_delegate) {
                QYstudent *student=[QYstudent new];
                [student setValuesForKeysWithDictionary:pars];
                [_delegate sendValue:student];
            }
            //插入数据成功
            dispatch_async(dispatch_get_main_queue(), ^{
            [vc.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
