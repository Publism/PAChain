//
//  VerifyConfirmViewController.m
//  VoteDemo
//


#import "VerifyConfirmViewController.h"

@interface VerifyConfirmViewController (){
    CustomTextfield *codeTF;
}
@property (nonatomic,copy)NSString *encToken;
@end

@implementation VerifyConfirmViewController

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
    self.title = @"Verify Vote";
    
    [self configMainView];
}

- (void)configMainView{
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), YHEIGHT_SCALE(108)+Height_NavBar, FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(40))];
    titleLab.text = @"Enter the code the SOE just texted you";
    titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(30)];
    [self.view addSubview:titleLab];
    
    int a = arc4random() % 100000;
    NSString *codeText = [NSString stringWithFormat:@"%06d", a];
    
    codeTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(titleLab.frame)+YHEIGHT_SCALE(28), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72))];
    codeTF.insetX = 10;
    codeTF.text = codeText;
    [self.view addSubview:codeTF];
    
    UIButton *fourthNextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fourthNextBtn.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(codeTF.frame)+YHEIGHT_SCALE(40), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72));
    [fourthNextBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
    [fourthNextBtn setTitle:@"Next" forState:UIControlStateNormal];
    [fourthNextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fourthNextBtn];
    
    UILabel *requestTip = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(fourthNextBtn.frame)+YHEIGHT_SCALE(60), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(80))];
    requestTip.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    requestTip.textAlignment = NSTextAlignmentCenter;
    requestTip.text = @"It may take a few minutes to receive your code, Still haven't received it?";
    requestTip.numberOfLines = 0;
    [self.view addSubview:requestTip];
    
    UIButton *requestbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    requestbtn.frame = CGRectMake((FUll_VIEW_WIDTH-YWIDTH_SCALE(340))/2, CGRectGetMaxY(requestTip.frame)+YHEIGHT_SCALE(60), YWIDTH_SCALE(340), YHEIGHT_SCALE(60));
    [requestbtn setTitle:@"Request new code" forState:UIControlStateNormal];
    [requestbtn setTitleColor:HexRGBAlpha(0x0390fc, 1) forState:UIControlStateNormal];
    [requestbtn addTarget:self action:@selector(requestbtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requestbtn];
}

- (void)nextBtnClick{
    CameraViewController *vc = [[CameraViewController alloc]init];
    vc.sessionType = @"1";
    vc.ReturnImageBlock = ^(UIImage * _Nonnull image) {
        [self confirmVoteRequest];
    };
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)confirmVoteRequest{
    [VoteDemoHUD showLoding];
    NSString *signature = [UserManager userInfo].accessTokenSignature;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        dispatch_group_async(group, queue, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *currrntDate = [formatter stringFromDate:date];
            NSDictionary *signDic = @{@"signature":signature,
                                      @"verifiedDate":currrntDate
            };
            [HttpTool encryDataRequest:[CustomMethodTool toJsonStrWithDictionary:signDic] withUrl:@"" success:^(id  _Nullable data) {
                self.encToken = [NSString stringWithFormat:@"%@",data];
                dispatch_semaphore_signal(semaphore);
            } failure:^(NSString * _Nullable error) {
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            NSDictionary *para = @{@"accessToken":[UserManager userInfo].accessToken,
                                   @"params":self.encToken.length>0?self.encToken:@""
            };
            [HttpTool requestWithUrl:@"confirmvoted" withDictionary:para success:^(id  _Nullable data) {
                NSLog(@"%@",data);
                NSString *ret = [NSString stringWithFormat:@"%@",data[@"ret"]];
                if ([ret isEqualToString:@"1"]) {
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 3)] animated:YES];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"verifyvotesuccess" object:nil];
                }
                [VoteDemoHUD hideLoding];
            } failure:^(NSString * _Nullable error) {
                [VoteDemoHUD hideLoding];
            }];
        });
    });
}

- (void)requestbtnClick{
    codeTF.text = [NSString stringWithFormat:@"%06d", arc4random() % 100000];
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
