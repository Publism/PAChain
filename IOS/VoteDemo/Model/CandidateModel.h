

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CandidateModel : NSObject
@property (nonatomic,assign)NSInteger candidateid;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *party;
@property (nonatomic,copy)NSString *photo;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,assign)BOOL isSelect;
@end

NS_ASSUME_NONNULL_END
