//
//  QYUpdateVC.h
//  01-数据持久化作业
//
//  Created by qingyun on 16/6/20.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYstudent;

typedef void(^block)(QYstudent *mode);


@interface QYUpdateVC : UIViewController
@property(nonatomic,strong)QYstudent *mode;

@property(nonatomic,strong)block Block;
@end
