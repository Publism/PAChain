//
//  MainViewController.m
//  VoteDemo
//


#import "MainViewController.h"
#import "BallotsViewController.h"
#import "HomeViewController.h"
#import "RSATool.h"
#import "RSAEncryptor.h"
@interface MainViewController (){
    UIView *backView;
}
@property (nonatomic,copy)NSString *encToken;
@property (nonatomic,retain)NSMutableArray *onionKeyArray;
@property (nonatomic,copy)NSString *package;
@property (nonatomic,copy)NSString *encryptKey;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _onionKeyArray = [[NSMutableArray alloc]init];
    _encryptKey = [[NSString alloc]init];
    _package = [[NSString alloc]init];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT);
    [btn setTitle:@"GOTV" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTitleColor:HexRGBAlpha(0x888888, 1) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnClick:(UIButton *)sender{
    if ([CustomMethodTool connectedToNetwork]) {
        NSString *encKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"encryptpublickey"];
        if (encKey.length<=0) {
            [HttpTool getPublicKeySuccess:^(id  _Nullable data) {
                [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"encryptpublickey"];
            }];
        }
        if ([UserManager userInfo].accessToken.length <= 0) {
            HomeViewController *vc = [[HomeViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            BallotsViewController *ballotVC = [[BallotsViewController alloc]init];
            [self.navigationController pushViewController:ballotVC animated:YES];
        }
    }else{
        [VoteDemoHUD setHUD:@"Network connection failure"];
    }
}

@end
