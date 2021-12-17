

#import "BallotHomeViewController.h"

@interface BallotHomeViewController ()<UITableViewDelegate,UITableViewDataSource,BallotCellDelegate>
@property (nonatomic,retain)UITableView *ballotTab;
@property (nonatomic,retain)ElectionListModel *electionModel;
@property (nonatomic,retain)NSMutableArray *seatArray;
@property (nonatomic,assign)BOOL isShowSelect;
@property (nonatomic,retain)NSMutableArray *voteCandidateArray;
@property (nonatomic,retain)UIView *bottomView;
@property (nonatomic,copy)NSString *verifyTip;
@property (nonatomic,assign)CGFloat verifyTipHeight;
@property (nonatomic,retain)NSDictionary *savedVoteDic;
@property (nonatomic,retain)UIView *alertView;
@end

@implementation BallotHomeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"My Ballots";
    _savedVoteDic = [[NSDictionary alloc]init];
    if ([_type isEqualToString:@"verify"]) {
        self.title = @"Verify Vote";
        _verifyTip = @"Please make sure that you have voted for this ballot on October 24, 2020. If you find that this ballot was not voted by yourself, you can report to SOE here.\n\nThank you for your confirmation.";
        if (_ballotModel.isconfirm) {
            _verifyTip = @"You have confirmed your vote.";
        }
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGRect rect = [_verifyTip boundingRectWithSize:CGSizeMake(FUll_VIEW_WIDTH-YWIDTH_SCALE(60), CGFLOAT_MAX) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
        _verifyTipHeight = rect.size.height;
    }else{
        if ([UserManager userInfo].unSubmitVoteJson.length > 0) {
            NSArray *array = [CustomMethodTool stringToJSONArray:[UserManager userInfo].unSubmitVoteJson];
            for (NSDictionary *dic in array) {
                NSString *ballotNo = [NSString stringWithFormat:@"%@",dic[@"ballotNumber"]];
                if ([ballotNo isEqualToString:_ballotModel.ballotno]) {
                    _savedVoteDic = dic;
                    break;
                }
            }
        }
    }
    
    _seatArray = [[NSMutableArray alloc]init];
    _voteCandidateArray = [[NSMutableArray alloc]init];
    if (_ballotModel.elections.count > 0) {
        _electionModel = [_ballotModel.elections firstObject];
        if (_electionModel.seats.count > 0) {
            [_seatArray removeAllObjects];
            for (SeatListModel *model in _electionModel.seats) {
                for (CandidateModel *candidate in model.candidates) {
                    NSArray *canArray = _savedVoteDic[@"candidateIDs"];
                    if (![canArray isKindOfClass:[NSNull class]] && canArray.count > 0) {
                        if ([canArray containsObject:@(candidate.candidateid)]) {
                            candidate.isSelect = YES;
                        }
                    }
                }
                [_seatArray addObject:model];
            }
        }
        [self ballotTab];
    }
    [self configBottomView];
}

- (void)configBottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, FUll_VIEW_HEIGHT-YHEIGHT_SCALE(120), FUll_VIEW_WIDTH, YHEIGHT_SCALE(120))];
        _bottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_bottomView];
        //Please confirm that this vote was voted by yourself:
        
        if ([_type isEqualToString:@"verify"] && !_ballotModel.isconfirm) {
            
            _bottomView.frame = CGRectMake(0, FUll_VIEW_HEIGHT-YHEIGHT_SCALE(180), FUll_VIEW_WIDTH, YHEIGHT_SCALE(180));
            
            UILabel *confirmTip = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), 0, FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
            confirmTip.text = @"Please confirm the vote was voted by yourself:";
            confirmTip.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
            [_bottomView addSubview:confirmTip];
            
            UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            sureBtn.frame = CGRectMake(YWIDTH_SCALE(50), CGRectGetMaxY(confirmTip.frame)+YHEIGHT_SCALE(30), YWIDTH_SCALE(300), YHEIGHT_SCALE(60));
            [sureBtn setTitle:@"Yes, I'm sure" forState:UIControlStateNormal];
            [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            sureBtn.layer.borderWidth = 1;
            sureBtn.layer.borderColor = [UIColor blackColor].CGColor;
            sureBtn.layer.cornerRadius = YHEIGHT_SCALE(60)/2;
            [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:sureBtn];
            
            UIButton *notSureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            notSureBtn.frame = CGRectMake(FUll_VIEW_WIDTH/2+YWIDTH_SCALE(25), CGRectGetMaxY(confirmTip.frame)+YHEIGHT_SCALE(30), YWIDTH_SCALE(300), YHEIGHT_SCALE(60));
            [notSureBtn setTitle:@"No,  it's not me" forState:UIControlStateNormal];
            [notSureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            notSureBtn.layer.borderWidth = 1;
            notSureBtn.layer.borderColor = [UIColor blackColor].CGColor;
            notSureBtn.layer.cornerRadius = YHEIGHT_SCALE(60)/2;
            [notSureBtn addTarget:self action:@selector(notSureBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:notSureBtn];
            
            _bottomView.hidden = ([_type isEqualToString:@"verify"] && !_ballotModel.isconfirm)?NO:YES;
            
        }else{
            UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            saveBtn.frame = CGRectMake(YWIDTH_SCALE(36), YHEIGHT_SCALE(30), YWIDTH_SCALE(150), YHEIGHT_SCALE(60));
            [saveBtn setTitle:@"Save" forState:UIControlStateNormal];
            [saveBtn setTitleColor:HexRGBAlpha(0x0390fc, 1) forState:UIControlStateNormal];
            saveBtn.layer.borderWidth = 1;
            saveBtn.layer.borderColor = HexRGBAlpha(0x0390fc, 1).CGColor;
            saveBtn.layer.cornerRadius = 4;
            [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:saveBtn];
            
            UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelBtn.frame = CGRectMake(YWIDTH_SCALE(36)+CGRectGetMaxX(saveBtn.frame), YHEIGHT_SCALE(30), YWIDTH_SCALE(150), YHEIGHT_SCALE(60));
            [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
            [cancelBtn setTitleColor:HexRGBAlpha(0x888888, 1) forState:UIControlStateNormal];
            cancelBtn.layer.borderWidth = 1;
            cancelBtn.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
            cancelBtn.layer.cornerRadius = 4;
            [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:cancelBtn];
            
            UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            submitBtn.frame = CGRectMake(FUll_VIEW_WIDTH-YWIDTH_SCALE(36)-YWIDTH_SCALE(150), YHEIGHT_SCALE(30), YWIDTH_SCALE(150), YHEIGHT_SCALE(60));
            [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
            [submitBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
            submitBtn.layer.cornerRadius = 4;
            [submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:submitBtn];
            
            NSArray *canArray = _savedVoteDic[@"candidateIDs"];
            if (![canArray isKindOfClass:[NSNull class]] && canArray.count > 0 && !_ballotModel.isvoted) {
                _bottomView.hidden = NO;
            }else{
                _bottomView.hidden = YES;
            }
            
        }
    }
    
}

- (UITableView *)ballotTab{
    if (!_ballotTab) {
        _ballotTab = [[UITableView alloc]initWithFrame:CGRectMake(0, Height_NavBar, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar) style:UITableViewStyleGrouped];
        _ballotTab.backgroundColor = [UIColor whiteColor];
        _ballotTab.bounces = NO;
        _ballotTab.dataSource = self;
        _ballotTab.delegate = self;
        [self.view addSubview:_ballotTab];
        if (([_type isEqualToString:@"verify"] && !_ballotModel.isconfirm)) {
            _ballotTab.height = FUll_VIEW_HEIGHT-Height_NavBar-YHEIGHT_SCALE(180);
        }else if (_ballotModel.isvoted){
            
        }else{
            NSArray *canArray = _savedVoteDic[@"candidateIDs"];
            if (![canArray isKindOfClass:[NSNull class]] && canArray.count > 0) {
                _ballotTab.height = FUll_VIEW_HEIGHT-Height_NavBar-YHEIGHT_SCALE(120);
            }
        }
    }
    return _ballotTab;;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _electionModel.seats.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SeatListModel *model = _electionModel.seats[section];
    return model.candidates.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return YHEIGHT_SCALE(240);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section > 0) {
        return YHEIGHT_SCALE(80);
    }else{
        if (_verifyTip.length > 0) {
            CGFloat headerHeight = YHEIGHT_SCALE(180)+_verifyTipHeight+YHEIGHT_SCALE(60);
            if (_ballotModel.isconfirm) {
                headerHeight = headerHeight-YHEIGHT_SCALE(20);
            }
            return headerHeight;
        }else if (_isSample){
            return YHEIGHT_SCALE(190)+YHEIGHT_SCALE(40);
        }else{
            return YHEIGHT_SCALE(190)+YHEIGHT_SCALE(40);
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_ballotModel.isvoted) {
        if (_electionModel.seats.count-1 == section) {
            return YHEIGHT_SCALE(160);
        }else{
            return CGFLOAT_MIN;
        }
    }else{
        return CGFLOAT_MIN;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BallotTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[BallotTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if ([UserManager userInfo].votedJson.length>0) {
        NSString *votejson = [RSATool decryptString:[UserManager userInfo].votedJson privateKey:[UserManager userInfo].privateKey];
        cell.voteJSON = votejson;
    }
    cell.showSelect = _isSample?NO:[_type isEqualToString:@"verify"]?NO:!_ballotModel.isvoted;
    cell.saveDic = _savedVoteDic;
    SeatListModel *model = _electionModel.seats[indexPath.section];
    cell.model = model.candidates[indexPath.row];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *iden = [NSString stringWithFormat:@"header%ld",(long)section];
    BallotHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:iden];
    if (!header) {
        header = [[BallotHeader alloc] initWithReuseIdentifier:iden];
    }
    if ([_type isEqualToString:@"verify"]) {
        header.verifyTipStr = _verifyTip;
        header.isConfirm = _ballotModel.isconfirm;
    }
    header.section = section;
    header.isSample = _isSample;
    header.model = _electionModel.election;
    header.seatModel = _electionModel.seats[section];
    header.viewProgress = ^(BOOL isView) {
        VotingProgressViewController *vc = [[VotingProgressViewController alloc]init];
        vc.ballotModel = self.ballotModel;
        [self.navigationController pushViewController:vc animated:YES];
    };
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]init];
    footerView.backgroundColor = [UIColor whiteColor];
    
    if (_ballotModel.isvoted && _electionModel.seats.count-1 == section) {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, YHEIGHT_SCALE(160))];
        lab.text = @"Voted √";
        lab.textColor = HexRGBAlpha(0x0390fc, 1);
        lab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
        lab.textAlignment = NSTextAlignmentCenter;
        [footerView addSubview:lab];
    }
    
    return footerView;
}

#pragma ballotCell delegate
- (void)voteClick:(BallotTableViewCell *)cell withModel:(CandidateModel *)model{
    BOOL hasSelect = NO;
    for (SeatListModel *semodel in _electionModel.seats) {
        for (CandidateModel *mmodel in semodel.candidates) {
            if ([semodel.seat.candidateids containsObject:@(model.candidateid)]) {
                if (mmodel.candidateid == model.candidateid) {
                    mmodel.isSelect = !mmodel.isSelect;
                }else{
                    mmodel.isSelect = NO;
                }
            }
            if (mmodel.isSelect) {
                hasSelect = YES;
            }
        }
    }
    
    if (hasSelect) {
        _bottomView.hidden = NO;
        _ballotTab.frame = CGRectMake(0, Height_NavBar, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar-YHEIGHT_SCALE(120));
    }else{
        _bottomView.hidden = YES;
        _ballotTab.frame = CGRectMake(0, Height_NavBar, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar);
    }
    [_ballotTab reloadData];
}

#pragma mark - Vote Method
- (void)saveBtnClick{
    NSMutableArray *unSubmitArray = [[NSMutableArray alloc]init];
    for (SeatListModel *semodel in _electionModel.seats) {
        NSMutableArray *seleArray = [[NSMutableArray alloc]init];
        for (CandidateModel *model in semodel.candidates) {
            if (model.isSelect) {
                [seleArray addObject:@(model.candidateid)];
            }
        }
        NSDictionary *dic = @{@"electionID":_electionModel.election.electionid,
                              @"seatID":@(1),
                              @"candidateIDs":seleArray,
                              @"ballotNumber":_ballotModel.ballotno
        };
        if ([UserManager userInfo].unSubmitVoteJson.length > 0) {
            unSubmitArray = [[CustomMethodTool stringToJSONArray:[UserManager userInfo].unSubmitVoteJson] mutableCopy];
            NSMutableArray *muArray = [[CustomMethodTool stringToJSONArray:[UserManager userInfo].unSubmitVoteJson] mutableCopy];
            for (NSDictionary *votedic in muArray) {
                NSString *ballotno = [NSString stringWithFormat:@"%@",votedic[@"ballotNumber"]];
                if ([ballotno isEqualToString:_ballotModel.ballotno]) {
                    [unSubmitArray removeObject:votedic];
                }
            }
        }
        [unSubmitArray addObject:dic];
    }
    NSString *jsonStr = [CustomMethodTool arrayToJSONString:unSubmitArray];
    NSDictionary *para = @{@"unSubmitVoteJson":jsonStr};
    [UserManager updateUserInfoWithDictionary:para];
    
    [VoteDemoHUD setHUD:@"Save Successfully"];
}

- (void)cancelBtnClick{
    
    if ([UserManager userInfo].unSubmitVoteJson.length > 0) {
        NSMutableArray *unSubmitArray = [[CustomMethodTool stringToJSONArray:[UserManager userInfo].unSubmitVoteJson] mutableCopy];
        NSMutableArray *muArray = [[CustomMethodTool stringToJSONArray:[UserManager userInfo].unSubmitVoteJson] mutableCopy];
        for (NSDictionary *votedic in muArray) {
            NSString *ballotno = [NSString stringWithFormat:@"%@",votedic[@"ballotNumber"]];
            if ([ballotno isEqualToString:_ballotModel.ballotno]) {
                [unSubmitArray removeObject:votedic];
            }
        }
        NSString *jsonStr = [CustomMethodTool arrayToJSONString:unSubmitArray];
        NSDictionary *para = @{@"unSubmitVoteJson":jsonStr.length>0?jsonStr:@""};
        [UserManager updateUserInfoWithDictionary:para];
    }

    for (SeatListModel *semodel in _electionModel.seats) {
        for (CandidateModel *model in semodel.candidates) {
            model.isSelect = NO;
        }
    }
    _bottomView.hidden = YES;
    _ballotTab.frame = CGRectMake(0, Height_NavBar, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar);
    self.isShowSelect = YES;
    [self.ballotTab reloadData];
}

- (void)submitBtnClick{
    
    NSMutableArray *muarray = [[NSMutableArray alloc]init];
    for (SeatListModel *semodel in _electionModel.seats) {
        NSMutableArray *seleArray = [[NSMutableArray alloc]init];
        for (CandidateModel *model in semodel.candidates) {
            if (model.isSelect) {
                NSDictionary *dic = @{@"id":@(model.candidateid),@"name":model.name};
                [seleArray addObject:dic];
            }
        }
        if (seleArray.count > 0) {
            NSDictionary *dic = @{@"electionID":_electionModel.election.electionid,
                                  @"seatID":@(semodel.seat.seatid),
                                  @"candidates":seleArray
            };
            [muarray addObject:dic];
        }
    }
    
    ConfirmVoteViewController *vc = [[ConfirmVoteViewController alloc]init];
    vc.votingData = muarray;
    vc.ballotNumber = _ballotModel.ballotno;
    vc.eleModel = _electionModel.election;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Verify Method

- (void)sureBtnClick{
    VerifyConfirmViewController *vc = [[VerifyConfirmViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)notSureBtnClick{
    
    _alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT)];
    _alertView.backgroundColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:_alertView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backViewClick)];
    [_alertView addGestureRecognizer:tap];
    
    UIView *selectView = [[UIView alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(50), FUll_VIEW_HEIGHT/2-YHEIGHT_SCALE(200), FUll_VIEW_WIDTH-YWIDTH_SCALE(100), YHEIGHT_SCALE(400))];
    selectView.backgroundColor = [UIColor whiteColor];
    [_alertView addSubview:selectView];
    
    NSString *noinfo =@"You confirm that the ballot was not voted by yourself, please contact your local SOE.";
    YYLabel *tipLab = [[YYLabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(30), FUll_VIEW_WIDTH-YWIDTH_SCALE(160), YHEIGHT_SCALE(160))];
    tipLab.textColor = [UIColor blackColor];
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:noinfo];
    one.yy_font =[UIFont systemFontOfSize:YFONTSIZEFROM_PX(34)];
    NSRange range = [noinfo rangeOfString:@" your local SOE"];
    [one addAttributes:@{NSForegroundColorAttributeName:HexRGBAlpha(0x0090ff, 1)} range:range];
    tipLab.attributedText = one;
    tipLab.numberOfLines = 0;
    [selectView addSubview:tipLab];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectViewClick)];
    [tipLab addGestureRecognizer:tap2];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(YWIDTH_SCALE(40), CGRectGetMaxY(tipLab.frame)+YHEIGHT_SCALE(30), tipLab.width-YWIDTH_SCALE(20), YHEIGHT_SCALE(72));
    [nextBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
    [nextBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [selectView addSubview:nextBtn];
    
    selectView.height = CGRectGetMaxY(nextBtn.frame)+YHEIGHT_SCALE(40);
    selectView.layer.cornerRadius = 6;
    
}

- (void)nextBtnClick{
    [self.alertView removeFromSuperview];
}

- (void)selectViewClick{
    RegisterLinkModel *model = [RegisterLinkModel getRegisterLinkWithState:[UserManager userInfo].state withCounty:[UserManager userInfo].county];
    if (model.RegisterLink.length > 0) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.RegisterLink] options:@{} completionHandler:^(BOOL success) {
                [self.alertView removeFromSuperview];
            }];
        } else {

        }
    }
}

- (void)backViewClick{
    [self.alertView removeFromSuperview];
}

@end
