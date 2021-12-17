

#import "BallotHeader.h"

@interface BallotHeader () {
    UILabel *eleLab;
    UILabel *eleDateLab;
    UILabel *color;
    UILabel *seatLab;
    UILabel *tipLab;
    UIButton *voteProgressBtn;
}

@end

@implementation BallotHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        voteProgressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voteProgressBtn.frame = CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(20), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40));
        [voteProgressBtn setTitle:@"View the voting progress" forState:UIControlStateNormal];
        [voteProgressBtn setTitleColor:HexRGBAlpha(0x0390fc, 1) forState:UIControlStateNormal];
        voteProgressBtn.titleLabel.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
        voteProgressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.contentView addSubview:voteProgressBtn];
        
        eleLab = [[UILabel alloc]init];
        eleLab.textAlignment = NSTextAlignmentCenter;
        eleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)];
        [self.contentView addSubview:eleLab];
        eleLab.frame = CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(20)+CGRectGetMaxY(voteProgressBtn.frame), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40));
        
        eleDateLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(eleLab.frame), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(30))];
        eleDateLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
        eleDateLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:eleDateLab];
        
        color = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(eleDateLab.frame)+YHEIGHT_SCALE(20), YWIDTH_SCALE(8), YHEIGHT_SCALE(40))];
        color.backgroundColor = HexRGBAlpha(0x0090ff, 1);
        [self.contentView addSubview:color];
        
        seatLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(50), CGRectGetMaxY(eleDateLab.frame)+YHEIGHT_SCALE(20), FUll_VIEW_WIDTH-YWIDTH_SCALE(110), YHEIGHT_SCALE(40))];
        seatLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(32)];
        [self.contentView addSubview:seatLab];
        
        tipLab = [[UILabel alloc]init];
        tipLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        tipLab.numberOfLines = 0;
        [self.contentView addSubview:tipLab];
        
    }
    return self;
}

- (void)setSeatModel:(SeatListModel *)seatModel{
    _seatModel = seatModel;
    seatLab.text = [seatModel.seat.name isEqualToString:seatModel.seat.office]?seatModel.seat.name:[NSString stringWithFormat:@"%@ %@",seatModel.seat.office,seatModel.seat.name];
}

- (void)setModel:(ElectionModel *)model{
    _model = model;
    
    
    if (_section > 0) {
        voteProgressBtn.hidden = YES;
        color.frame = CGRectMake(YWIDTH_SCALE(30),YHEIGHT_SCALE(20), YWIDTH_SCALE(8), YHEIGHT_SCALE(40));
        seatLab.frame = CGRectMake(YWIDTH_SCALE(50),YHEIGHT_SCALE(20), FUll_VIEW_WIDTH-YWIDTH_SCALE(110), YHEIGHT_SCALE(40));
    }else{
        eleLab.text = model.electionname;
        eleDateLab.text = [model.electiondate transformDateStringWithFormat:@"yyyy-MM-dd" toformat:@"MMM. dd, yyyy"];
        if (_verifyTipStr.length > 0) {
            voteProgressBtn.hidden = YES;
            eleLab.frame = CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(40), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40));
            eleDateLab.frame = CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(eleLab.frame), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(30));
            
            NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
            CGRect rect = [_verifyTipStr boundingRectWithSize:CGSizeMake(FUll_VIEW_WIDTH-YWIDTH_SCALE(60), CGFLOAT_MAX) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
            
            if (!_isConfirm) {
                UILabel *gray = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(eleDateLab.frame)+YHEIGHT_SCALE(10), FUll_VIEW_WIDTH, YHEIGHT_SCALE(10))];
                gray.backgroundColor = HexRGBAlpha(0xf6f6f6, 1);
                [self.contentView addSubview:gray];
                
                tipLab.frame = CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(gray.frame)+YHEIGHT_SCALE(10), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), rect.size.height);
            }else{
                tipLab.frame = CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(eleDateLab.frame)+YHEIGHT_SCALE(10), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), rect.size.height);
            }
            
            tipLab.text = _verifyTipStr;
            tipLab.textColor = HexRGBAlpha(0x888888, 1);
            
            
            UILabel *gray2 = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tipLab.frame)+YHEIGHT_SCALE(10), FUll_VIEW_WIDTH, YHEIGHT_SCALE(10))];
            gray2.backgroundColor = HexRGBAlpha(0xf6f6f6, 1);
            [self.contentView addSubview:gray2];
            
            color.frame = CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(gray2.frame)+YHEIGHT_SCALE(20), YWIDTH_SCALE(8), YHEIGHT_SCALE(40));
            seatLab.y = color.y;
        }else if (_isSample){
            [voteProgressBtn setTitle:@"Sample Ballot" forState:UIControlStateNormal];
            [voteProgressBtn setTitleColor:HexRGBAlpha(0x888888, 1) forState:UIControlStateNormal];
        }else{
            [voteProgressBtn addTarget:self action:@selector(progressClick) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)progressClick{
    if (self.viewProgress) {
        self.viewProgress(YES);
    }
}

@end
