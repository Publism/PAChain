

#import "VerifycationCell.h"
#import "YYImage.h"

@interface VerifycationCell (){
    UIImageView *imageV;
    YYLabel *titleLab;
    UILabel *dateLab;
    UILabel *fingerPrintLab;
}
@property(retain,nonatomic) UISwitch * touchIDSwitch;
@end

@implementation VerifycationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        imageV = [[UIImageView alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(28), YWIDTH_SCALE(80), YWIDTH_SCALE(80))];
        imageV.layer.cornerRadius = YWIDTH_SCALE(40);
        imageV.layer.masksToBounds = YES;
        imageV.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:imageV];
        
        titleLab = [[YYLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageV.frame)+YWIDTH_SCALE(36), imageV.y, FUll_VIEW_WIDTH-YWIDTH_SCALE(66)-CGRectGetMaxX(imageV.frame), YHEIGHT_SCALE(40))];
        titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(32)];
        [self.contentView addSubview:titleLab];
        
        dateLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageV.frame)+YWIDTH_SCALE(36), CGRectGetMaxY(titleLab.frame), FUll_VIEW_WIDTH-YWIDTH_SCALE(66)-CGRectGetMaxX(imageV.frame), YHEIGHT_SCALE(40))];
        dateLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        [self.contentView addSubview:dateLab];
        
    }
    return self;
}

- (void)setIndex:(NSInteger)index{
    if (index == 0) {
        imageV.image = [UIImage imageNamed:@"Device"];
        NSMutableAttributedString *nameAtt = [[NSMutableAttributedString alloc]initWithString:@"Device"];
        nameAtt.yy_font =[UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(32)];
        if ([UserManager userInfo].userVerifyDate.length > 0) {
            YYAnimatedImageView *imageview = [[YYAnimatedImageView alloc]initWithImage:[UIImage imageNamed:@"complete"]];
            imageview.frame = CGRectMake(0, 0, YWIDTH_SCALE(40), YWIDTH_SCALE(40));
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageview contentMode:UIViewContentModeRight width:imageview.size.width+YWIDTH_SCALE(20) ascent:15 descent:0];
            [nameAtt appendAttributedString:attachText];
            titleLab.attributedText = nameAtt;
            dateLab.text = [NSString stringWithFormat:@"Verified %@",[[UserManager userInfo].userVerifyDate transformDateStringWithFormat:@"yyyy-MM-dd" toformat:@"MMM. dd, yyyy"]];
        }else{
            titleLab.text = @"Device";
            dateLab.text = @"Unverified";
        }
        
    }else if (index == 1) {
        NSData * imageData =[[NSData alloc] initWithBase64EncodedString:[UserManager userInfo].imageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
        imageV.image = [UIImage imageWithData:imageData ];
        
        if ([UserManager userInfo].userVerifyDate.length > 0) {
            NSMutableAttributedString *nameAtt = [[NSMutableAttributedString alloc]initWithString:@"My election officials"];
            nameAtt.yy_font =[UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(32)];
            YYAnimatedImageView *imageview = [[YYAnimatedImageView alloc]initWithImage:[UIImage imageNamed:@"complete"]];
            imageview.frame = CGRectMake(0, 0, YWIDTH_SCALE(40), YWIDTH_SCALE(40));
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageview contentMode:UIViewContentModeRight width:imageview.size.width+YWIDTH_SCALE(20) ascent:15 descent:0];
            [nameAtt appendAttributedString:attachText];
            titleLab.attributedText = nameAtt;
            dateLab.text = [NSString stringWithFormat:@"Verified %@",[[UserManager userInfo].userVerifyDate transformDateStringWithFormat:@"yyyy-MM-dd" toformat:@"MMM. dd, yyyy"]];
        }else{
            titleLab.text = @"My election officials";
            dateLab.text = @"Unverified";
        }
    }else if (index == 2){
        imageV.width = 0;
        titleLab.x = YWIDTH_SCALE(30);
        dateLab.x = YWIDTH_SCALE(30);
        titleLab.text = @"Verify Your Vote";
        dateLab.text = @"Only after you finish voting";
    }else if (index == 3 && _hasInvite){
        imageV.width = 0;
        titleLab.x = YWIDTH_SCALE(30);
        dateLab.x = YWIDTH_SCALE(30);
        titleLab.frame =CGRectMake(YWIDTH_SCALE(30), 0, FUll_VIEW_WIDTH-YWIDTH_SCALE(60)-YWIDTH_SCALE(100), YHEIGHT_SCALE(136));
        titleLab.text = @"Invitation";
        titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)];
    }else{
        imageV.hidden = YES;
        titleLab.hidden = YES;
        dateLab.hidden = YES;
        if (!fingerPrintLab) {
            fingerPrintLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), 0, FUll_VIEW_WIDTH-YWIDTH_SCALE(60)-YWIDTH_SCALE(100), YHEIGHT_SCALE(136))];
            fingerPrintLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)];
            fingerPrintLab.text = @"Enable Fingerprint Log In: ";
            [self.contentView addSubview:fingerPrintLab];
            
            _touchIDSwitch = [[UISwitch alloc]init];
            _touchIDSwitch.frame=CGRectMake(CGRectGetMaxX(fingerPrintLab.frame), fingerPrintLab.height/2-15, 35, 20);
            _touchIDSwitch.transform=CGAffineTransformMakeScale(0.7,0.7);
            if ([UserManager userInfo].canTouchIDVerify.length > 0 && [[UserManager userInfo].canTouchIDVerify isEqualToString:@"yes"]) {
                _touchIDSwitch.on = YES;
            }else{
                _touchIDSwitch.on = NO;
            }
            [self.contentView addSubview:_touchIDSwitch];
            [_touchIDSwitch setOnTintColor:HexRGBAlpha(0x0390fc, 1)];
            [_touchIDSwitch setThumbTintColor:[UIColor grayColor]];
            [_touchIDSwitch addTarget:self action:@selector(swChange:) forControlEvents:UIControlEventValueChanged];
        }
    }
}

- (void) swChange:(UISwitch*) sw{
    if(sw.on==YES){
        [self touchIDRecognition:YES];
    }else{
        [self touchIDRecognition:NO];
    }
}

- (void)touchIDRecognition:(BOOL)recog{
    if(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0)
    {
        _touchIDSwitch.on =!recog;
        [VoteDemoHUD setHUD:@"TouchID is not supported in the system version"];
    }else{
        LAContext *laContext = [[LAContext alloc] init];
        laContext.localizedFallbackTitle = @"";
        NSError *error;
        if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
            [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Please verify fingerprint" reply:^(BOOL success, NSError *error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (success) {
                        if (recog) {
                            NSDictionary *userDic = @{@"canTouchIDVerify":@"yes"};
                            [UserManager updateUserInfoWithDictionary:userDic];
                        }else{
                            NSDictionary *userDic = @{@"canTouchIDVerify":@"no"};
                            [UserManager updateUserInfoWithDictionary:userDic];
                        }
                        self.touchIDSwitch.on = recog;
                        [VoteDemoHUD setHUD:@"Successfully"];
                    }else{
                        self.touchIDSwitch.on =!recog;
                    }
                });
            }];
        }else {
            switch (error.code) {
                case LAErrorTouchIDNotEnrolled:
                {
                    _touchIDSwitch.on =!recog;
                    [VoteDemoHUD setHUD:@"TouchID is not enrolled"];
                    NSLog(@"TouchID is not enrolled");
                    break;
                }
                case LAErrorPasscodeNotSet:
                {
                    _touchIDSwitch.on =!recog;
                    [VoteDemoHUD setHUD:@"A passcode has not been set"];
                    NSLog(@"A passcode has not been set");
                    break;
                }
                default:
                {
                    _touchIDSwitch.on =!recog;
                    [VoteDemoHUD setHUD:@"TouchID not available"];
                    NSLog(@"TouchID not available");
                    break;
                }
            }
        }
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
