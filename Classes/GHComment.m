#import "GHComment.h"
#import "GHUser.h"
#import "NSDictionary+Extensions.h"
#import "iOctocat.h"


@implementation GHComment

- (void)setValues:(id)dict {
	self.body = [dict safeStringForKey:@"body"];
	self.createdAt = [dict safeDateForKey:@"created_at"];
	self.updatedAt = [dict safeDateForKey:@"updated_at"];
	self.user = [iOctocat.sharedInstance userWithLogin:[dict safeStringForKeyPath:@"user.login"]];
	if (!self.user.gravatarURL) {
		self.user.gravatarURL = [dict safeURLForKeyPath:@"user.avatar_url"];
	}
}

#pragma mark Saving

// Implement this in the subclass
- (NSString *)savePath {
	return nil;
}

- (void)saveWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	[self saveWithParams:params path:self.savePath method:kRequestMethodPost start:start success:^(GHResource *instance, id data) {
		[self setValues:data];
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

@end
