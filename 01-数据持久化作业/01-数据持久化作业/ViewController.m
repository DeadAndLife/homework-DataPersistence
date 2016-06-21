//
//  ViewController.m
//  01-数据持久化作业
//
//  Created by qingyun on 16/6/20.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "ViewController.h"
#import "AFNetWorking.h"
#import "QYstudent.h"
#import "QYDataBaseTool.h"
#import "QYsendPRo.h"
#import "QYinsertIntoVc.h"
#import "QYUpdateVC.h"

#define BASEURL @"http://afnetworking.sinaapp.com/persons.json"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,QYsendPRo,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong,nonatomic)UIRefreshControl *refreshControl;
@property (nonatomic)BOOL isRefrsh;
//存放数据源
@property(strong,nonatomic)NSMutableArray *dataArr;

@end

@implementation ViewController

-(void)requestPerson{
   //1.设置参数
    NSDictionary *pars=@{@"person_type":@"student"};
   //2.生成manager对象
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
   //3.Post请求
    __weak UITableView *tableView=_myTableView;
    __weak UIRefreshControl *refresh=_refreshControl;
    [manager POST:BASEURL parameters:pars progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //1.判断是否请求成功 200
        NSHTTPURLResponse *response=(NSHTTPURLResponse *)task.response;
        if (response.statusCode==200) {
        //2.取出数据===字典转mode
            NSArray *tempArr=responseObject[@"data"];
            if (_dataArr) {
            //判断是否下拉刷新
                if (_isRefrsh) {
                    [_dataArr removeAllObjects];
                    [refresh endRefreshing];
                   [QYDataBaseTool  updateStatementsSql:DeleteAll withParsmeters:nil block:^(BOOL isOk, NSString *errorMsg) {
                   }];
                }
            }else{
                _dataArr=[NSMutableArray array];
            }
          //mode
            for (NSDictionary *dic in tempArr) {
                //数据持久化
                [QYDataBaseTool updateStatementsSql:Inserinto withParsmeters:dic block:^(BOOL isOk, NSString *errorMsg) {
                    if (isOk) {
                        NSLog(@"insert OK");
                    }else{
                        NSLog(@"====%@",errorMsg);
                    }
                    
                }];
                
                QYstudent *student=[[QYstudent alloc] init];
                [student setValuesForKeysWithDictionary:dic];
                [_dataArr addObject:student];
            }
            
            [tableView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
    }];
}

-(void)refresh{
    //开始刷新
    _isRefrsh=YES;
    [self requestPerson];
}

-(void)addsubView{
    //下拉刷新
    _refreshControl=[[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [_myTableView addSubview:_refreshControl];
    
    //搜索框
    UISearchBar *bar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0,_myTableView.frame.size.width, 44)];
    bar.delegate=self;
    _myTableView.tableHeaderView=bar;
    
    
}

- (void)viewDidLoad {
    
    //1判断本地是否有存储数据
    __weak ViewController *controller=self;
    [QYDataBaseTool selectStatementsSql:selectAll withParsmeters:nil forMode:@"QYstudent" block:^(NSMutableArray *resposeOjbc, NSString *errorMsg) {
            if (resposeOjbc.count>0) {
                //从本地读取
                controller.dataArr=resposeOjbc;
                [controller.myTableView reloadData];
            }else{
                [controller requestPerson];
            }
    }];
    [self addsubView];
    [super viewDidLoad];
   // [self requestPerson];
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identfier=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identfier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identfier];
    }
    //取出mode ,赋值Ui
    QYstudent *mode=_dataArr[indexPath.row];
    cell.textLabel.text=mode.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"ID:%@     age:%@",mode.stu_id,mode.age];

    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
     //删除操作
    if(editingStyle==UITableViewCellEditingStyleDelete){
    //1.删除内存数据
        QYstudent *mode=_dataArr[indexPath.row];
        for (QYstudent *temp in _dataArr) {
            if ([temp.stu_id isEqualToString:mode.stu_id]) {
                [_dataArr removeObject:temp];
                break;
            }
        }
    //2删除表格cell
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     //3.删除数据库数据
        [QYDataBaseTool updateStatementsSql:DeleteStu_Id withParsmeters:@{@"stu_id":mode.stu_id} block:^(BOOL isOk, NSString *errorMsg) {
            if (isOk) {
                NSLog(@"删除成功");
            }
        }];
    }
    
    
    
}





#pragma mark tableView selected
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //.初始化控制对象
    QYUpdateVC *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"UpDateIdentfier"];
    //2.获取当前cell mode的值
    QYstudent *mode=_dataArr[indexPath.row];
    
    //3.将mode赋值给 控制器对象
    controller.mode=mode;
    __weak ViewController *vc=self;
    controller.Block=^(QYstudent *mode){
        int i=0;
        for (QYstudent *temp in _dataArr) {
            if ([temp.stu_id isEqualToString:mode.stu_id]) {
                [_dataArr replaceObjectAtIndex:i withObject:mode];
                break;
            }
            i++;
        }
        [vc.myTableView reloadData];
    };
    
    //压栈操作
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark QYsendPro 
-(void)sendValue:(id)value{
 //接收到协议的所有方法
    QYstudent *mode=(QYstudent *)value;
 //把mode添加到数组
   [_dataArr addObject:mode];
 //刷新UI
    [_myTableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        //获取到你要压栈过去的对象
        QYinsertIntoVc *intoVc=segue.destinationViewController;
        intoVc.delegate=self;
    }
}

#pragma mark searchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    //显示取消按钮
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
   //当你编辑变化的时候,该方法会触发
    NSLog(@"====%@===%@",searchBar.text,searchText);
   //进行模糊查询
    __weak ViewController *vc=self;
    [QYDataBaseTool selectStatementsSql:selectChar(searchText) withParsmeters:nil forMode:@"QYstudent" block:^(NSMutableArray *resposeOjbc, NSString *errorMsg) {
        vc.dataArr=resposeOjbc;
        
        [vc.myTableView reloadData];
    }];
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
  //失去第一响应
    [searchBar resignFirstResponder];
    //隐藏按钮
    [searchBar setShowsCancelButton:NO animated:YES];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
