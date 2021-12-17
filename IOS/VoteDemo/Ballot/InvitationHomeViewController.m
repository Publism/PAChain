//
//  InvitationHomeViewController.m
//  VoteDemo


#import "InvitationHomeViewController.h"

@interface InvitationHomeViewController ()
@property (nonatomic,retain)UIButton *submitBtn;
@property (nonatomic,assign)NSInteger selectStatus;
@property (nonatomic,copy)NSString *encToken;
@end

@implementation InvitationHomeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
}

- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Invitation";
    _selectStatus = _dataModel.status;
    [self configMainView];
}

- (void)configMainView{
    NSString *ballotDate = [_dataModel.ballotdate transformDateStringWithFormat:@"yyyy-MM-dd" toformat:@"MMM. dd, yyyy"];
    NSString *ballotName = [NSString stringWithFormat:@"Invitation for %@\n%@",_dataModel.ballotname,ballotDate];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:ballotName];
    [attr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)]} range:[ballotName rangeOfString:[NSString stringWithFormat:@"Invitation for %@",_dataModel.ballotname]]];
    
    UILabel *ballotLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), Height_NavBar+YHEIGHT_SCALE(40), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), FUll_VIEW_HEIGHT-Height_NavBar)];
    ballotLab.attributedText = attr;
    ballotLab.numberOfLines = 0;
    [self.view addSubview:ballotLab];
    [ballotLab sizeToFit];
    
    NSString *tipStr = [NSString stringWithFormat:@"Please tell us whether you accept voting via your mobile phone\n\nYour current status: %@\n\nPlease chooose:",_dataModel.status==0?@"No response":@"Responsed"];
    NSMutableAttributedString *tipAttr = [[NSMutableAttributedString alloc]initWithString:tipStr];
    [tipAttr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)]} range:[tipStr rangeOfString:@"Responsed"]];
    [tipAttr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)]} range:[tipStr rangeOfString:@"No response"]];
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(ballotLab.frame)+YHEIGHT_SCALE(40), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(100))];
    tipLab.attributedText = tipAttr;
    tipLab.numberOfLines = 0;
    [self.view addSubview:tipLab];
    [tipLab sizeToFit];
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(tipLab.frame)+YHEIGHT_SCALE(40), YWIDTH_SCALE(50), YWIDTH_SCALE(50));
    if (_dataModel.status == 1) {
        [selectBtn setBackgroundImage:[UIImage imageNamed:@"check-in"] forState:UIControlStateNormal];
        selectBtn.selected = YES;
    }else{
        [selectBtn setBackgroundImage:[UIImage imageNamed:@"check-out"] forState:UIControlStateNormal];
        selectBtn.selected = NO;
    }
    [self.view addSubview:selectBtn];
    
    UILabel *selectLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(selectBtn.frame)+YWIDTH_SCALE(30), selectBtn.y, FUll_VIEW_WIDTH-CGRectGetMaxX(selectBtn.frame)-YWIDTH_SCALE(60), YHEIGHT_SCALE(50))];
    selectLab.text = @"Yes, I will vote via mobile";
    [self.view addSubview:selectLab];
    
    UIButton *unSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unSelectBtn.frame = CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(selectBtn.frame)+YHEIGHT_SCALE(40), YWIDTH_SCALE(50), YWIDTH_SCALE(50));
    if (_dataModel.status == 2) {
        [unSelectBtn setBackgroundImage:[UIImage imageNamed:@"check-in"] forState:UIControlStateNormal];
        unSelectBtn.selected = YES;
    }else{
        [unSelectBtn setBackgroundImage:[UIImage imageNamed:@"check-out"] forState:UIControlStateNormal];
        unSelectBtn.selected = NO;
    }
    if (_selectStatus == 0) {
        [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [unSelectBtn addTarget:self action:@selector(unselectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:unSelectBtn];
    
    UILabel *unselectLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(unSelectBtn.frame)+YWIDTH_SCALE(30), unSelectBtn.y, FUll_VIEW_WIDTH-CGRectGetMaxX(unSelectBtn.frame)-YWIDTH_SCALE(60), YHEIGHT_SCALE(50))];
    unselectLab.text = @"No, I will not vote via mobile";
    [self.view addSubview:unselectLab];
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.frame = CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(unSelectBtn.frame)+YHEIGHT_SCALE(60), YWIDTH_SCALE(200), YHEIGHT_SCALE(72));
    [_submitBtn setBackgroundColor:[UIColor lightGrayColor]];
    [_submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _submitBtn.userInteractionEnabled = NO;
    [self.view addSubview:_submitBtn];
}

- (void)selectBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundImage:[UIImage imageNamed:@"check-in"] forState:UIControlStateNormal];
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]] && ![btn isEqual:sender] && ![btn isEqual:_submitBtn]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"check-out"] forState:UIControlStateNormal];
                btn.selected = NO;
            }
        }
        _selectStatus = 1;
        [_submitBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
        _submitBtn.userInteractionEnabled = YES;
    }else{
        _selectStatus = 0;
        [_submitBtn setBackgroundColor:[UIColor lightGrayColor]];
        _submitBtn.userInteractionEnabled = NO;
        [sender setBackgroundImage:[UIImage imageNamed:@"check-out"] forState:UIControlStateNormal];
    }
}

- (void)unselectBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundImage:[UIImage imageNamed:@"check-in"] forState:UIControlStateNormal];
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]] && ![btn isEqual:sender] && ![btn isEqual:_submitBtn]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"check-out"] forState:UIControlStateNormal];
                btn.selected = NO;
            }
        }
        _selectStatus = 2;
        [_submitBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
        _submitBtn.userInteractionEnabled = YES;
    }else{
        _selectStatus = 0;
        [_submitBtn setBackgroundColor:[UIColor lightGrayColor]];
        _submitBtn.userInteractionEnabled = NO;
        [sender setBackgroundImage:[UIImage imageNamed:@"check-out"] forState:UIControlStateNormal];
    }
}

- (void)submitBtnClick{
    [VoteDemoHUD showLoding];
    NSString *signature = [UserManager userInfo].accessTokenSignature;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        dispatch_group_async(group, queue, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            NSDictionary *signDic = @{@"signature":signature,
                                      @"status":@(self.selectStatus)
            };
            [HttpTool encryDataRequest:[CustomMethodTool toJsonStrWithDictionary:signDic] withUrl:@"" success:^(id  _Nullable data) {
                self.encToken = [NSString stringWithFormat:@"%@",data];
                dispatch_semaphore_signal(semaphore);
            } failure:^(NSString * _Nullable error) {
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSDictionary *dic = @{@"accessToken":[UserManager userInfo].accessToken,
                                  @"params":self.encToken.length>0?self.encToken:@""
            };
            [HttpTool requestWithUrl:@"setvoteinvite" withDictionary:dic success:^(id  _Nullable data) {
                NSString *ret = [NSString stringWithFormat:@"%@",data[@"ret"]];
                if ([ret isEqualToString:@"1"]) {
                    [VoteDemoHUD hideLoding];
                    if (self.selectStatus == 1) {
                        [VoteDemoHUD setHUD:@"Thank you, we will provide you with official ballot before the election."];
                    }else{
                        [VoteDemoHUD setHUD:@"Thank you, please vote on election day."];
                    }
                    [self.submitBtn setBackgroundColor:[UIColor lightGrayColor]];
                    for (UIButton *btn in self.view.subviews) {
                        if ([btn isKindOfClass:[UIButton class]]) {
                            btn.userInteractionEnabled = NO;
                        }
                    }
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"inviterefresh" object:nil];
                }else{
                    [VoteDemoHUD hideLoding];
                }
            } failure:^(NSString * _Nullable error) {
                [VoteDemoHUD hideLoding];
            }];
        });
    });
    
    
}

@end
