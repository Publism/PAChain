//
//  InvitationModel.h
//  VoteDemo


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InvitationModel : NSObject
@property (nonatomic,copy)NSString *ballotdate;
@property (nonatomic,copy)NSString *ballotname;
@property (nonatomic,copy)NSString *ballotno;
@property (nonatomic,copy)NSString *invitedate;
@property (nonatomic,copy)NSString *userkey;
//0 send, 1 agress, 2 disagress
@property (nonatomic,assign)NSInteger status;
@end

NS_ASSUME_NONNULL_END
