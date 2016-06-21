//
//  QYUpdateVC.m
//  01-数据持久化作业
//
//  Created by qingyun on 16/6/20.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "QYUpdateVC.h"
#import "QYstudent.h"
#import "QYDataBaseTool.h"

@interface QYUpdateVC ()
@property (weak, nonatomic) IBOutlet UITextField *stuidTf;
@property (weak, nonatomic) IBOutlet UITextField *nameTf;
@property (weak, nonatomic) IBOutlet UITextField *ageTf;

@end

@implementation QYUpdateVC

-(void)loadData{
    _ageTf.text=_mode.age;
    _stuidTf.text=_mode.stu_id;
    _nameTf.text=_mode.name;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadData];
}

- (IBAction)updateAction:(id)sender {
  //执行更新操作
    //1.封装参数
    NSDictionary *pars=@{@"stu_id":_stuidTf.text,@"name":_nameTf.text,@"age":_ageTf.text};
    //2.执行sql语句
    __weak QYUpdateVC *vc=self;
    [QYDataBaseTool updateStatementsSql:UpdateSql withParsmeters:pars block:^(BOOL isOk, NSString *errorMsg) {
        if (isOk) {
         //回调
            QYstudent *mode=[QYstudent new];
            [mode setValuesForKeysWithDictionary:pars];
            self.Block(mode);
            [vc.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
