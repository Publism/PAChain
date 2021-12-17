

#import "BallotTableViewCell.h"
#import "YYLabel.h"
#import "YYImage.h"
@interface BallotTableViewCell () {
    UILabel *partyLab;
    UIImageView *candidatePhoto;
    YYLabel *candidateName;
    UIButton *votebtn;
}

@end

@implementation BallotTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        votebtn = [UIButton buttonWithType:UIButtonTypeCustom];
        votebtn.selected = NO;
        [votebtn setImage:[UIImage imageNamed:@"check-out"] forState:UIControlStateNormal];
        [votebtn addTarget:self action:@selector(voteSelected) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:votebtn];
        
        partyLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(20), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
        partyLab.text = @"Republican";
        partyLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)];
        [self.contentView addSubview:partyLab];
        
        //126 140
        candidatePhoto = [[UIImageView alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(partyLab.frame)+YHEIGHT_SCALE(20), YWIDTH_SCALE(126), YHEIGHT_SCALE(140))];
        candidatePhoto.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:candidatePhoto];
        
        candidateName = [[YYLabel alloc]init];
        candidateName.frame = CGRectMake(CGRectGetMaxX(candidatePhoto.frame)+YWIDTH_SCALE(20), candidatePhoto.y, FUll_VIEW_WIDTH-CGRectGetMaxX(candidatePhoto.frame)-YWIDTH_SCALE(50), YHEIGHT_SCALE(140));
        candidateName.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
        candidateName.textAlignment = NSTextAlignmentLeft;
        candidateName.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        candidateName.textColor = HexRGBAlpha(0x333333, 1);
        candidateName.numberOfLines = 0;
        [self.contentView addSubview:candidateName];
    }
    return self;
}

- (void)setModel:(CandidateModel *)model{
    _model = model;
    
    if (_showSelect) {
        
        candidatePhoto.frame = CGRectMake(YWIDTH_SCALE(30)+YWIDTH_SCALE(90), CGRectGetMaxY(partyLab.frame)+YHEIGHT_SCALE(20), YWIDTH_SCALE(126), YHEIGHT_SCALE(140));
        candidateName.frame = CGRectMake(CGRectGetMaxX(candidatePhoto.frame)+YWIDTH_SCALE(20), candidatePhoto.y, FUll_VIEW_WIDTH-CGRectGetMaxX(candidatePhoto.frame)-YWIDTH_SCALE(50), YHEIGHT_SCALE(140));
        votebtn.frame = CGRectMake(YWIDTH_SCALE(30), candidatePhoto.y+YHEIGHT_SCALE(40) , YWIDTH_SCALE(60), YHEIGHT_SCALE(60));
        
        if (model.isSelect) {
            [votebtn setImage:[UIImage imageNamed:@"check-in"] forState:UIControlStateNormal];
        }else{
            [votebtn setImage:[UIImage imageNamed:@"check-out"] forState:UIControlStateNormal];
        }
    }
    
    partyLab.text = model.party;
    [candidatePhoto sd_setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:[UIImage imageNamed:@"1.jpg"]];
    if (model.party.length > 0) {
        UIButton *partyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        partyBtn.frame = CGRectMake(candidatePhoto.width-YWIDTH_SCALE(35), candidatePhoto.height-YWIDTH_SCALE(35), YWIDTH_SCALE(35), YWIDTH_SCALE(35));
        partyBtn.titleLabel.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(28)];
        if ([model.party isEqualToString:@"Republican"]) {
            [partyBtn setTitle:@"R" forState:UIControlStateNormal];
            partyBtn.backgroundColor = [UIColor redColor];
        }else if ([model.party isEqualToString:@"Democratic"]){
            [partyBtn setTitle:@"D" forState:UIControlStateNormal];
            partyBtn.backgroundColor = [UIColor blueColor];
        }else if ([model.party isEqualToString:@"Independent"]){
            [partyBtn setTitle:@"I" forState:UIControlStateNormal];
            partyBtn.backgroundColor = HexRGBAlpha(0x9c17df, 1);
        }else{
            [partyBtn setTitle:@"O" forState:UIControlStateNormal];
            partyBtn.layer.borderWidth = 0.5;
            partyBtn.layer.borderColor = [UIColor grayColor].CGColor;
            [partyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            partyBtn.backgroundColor = [UIColor whiteColor];
        }
            
        [candidatePhoto addSubview:partyBtn];
    }
    
    
    NSMutableAttributedString *nameAtt = [[NSMutableAttributedString alloc]initWithString:model.name];
    nameAtt.yy_font =[UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
    if (_voteJSON.length > 0) {
        NSArray *voteJsonArray = [CustomMethodTool stringToJSONArray:_voteJSON];
        if (voteJsonArray.count > 0) {
            BOOL isvoted = NO;
            for (NSDictionary *voteDic in voteJsonArray) {
                NSArray *candidateArray = voteDic[@"candidates"];
                for (NSDictionary *dic in candidateArray) {
                    NSString *canID = [NSString stringWithFormat:@"%@",dic[@"id"]];
                    if ([canID integerValue] == model.candidateid) {
                        isvoted = YES;
                        break;
                    }
                }
            }
            if (isvoted) {
                YYAnimatedImageView *imageview = [[YYAnimatedImageView alloc]initWithImage:[UIImage imageNamed:@"complete"]];
                imageview.frame = CGRectMake(0, 0, YWIDTH_SCALE(40), YWIDTH_SCALE(40));
                NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageview contentMode:UIViewContentModeRight width:imageview.size.width+YWIDTH_SCALE(20) ascent:5 descent:0];
                [nameAtt appendAttributedString:attachText];
            }
        }
    }
    candidateName.attributedText = nameAtt;
    [candidateName sizeToFit];
}

- (void)voteSelected{
    if (self.delegate && [self.delegate respondsToSelector:@selector(voteClick:withModel:)]) {
        [self.delegate voteClick:self withModel:_model];
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
