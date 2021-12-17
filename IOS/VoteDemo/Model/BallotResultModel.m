//
//  BallotResultModel.m
//  VoteDemo
//


#import "BallotResultModel.h"

@implementation BallotResultModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"candidates" : [CandidateModel class]};
}
@end
