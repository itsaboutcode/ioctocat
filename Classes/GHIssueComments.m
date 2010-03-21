#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "GHIssue.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"


@interface GHIssueComments ()
- (void)parseComments;
@end


@implementation GHIssueComments

@synthesize comments;
@synthesize issue;

+ (id)commentsWithIssue:(GHIssue *)theIssue {
	return [[[[self class] alloc] initWithIssue:theIssue] autorelease];
}

- (id)initWithIssue:(GHIssue *)theIssue {
	[super init];
	self.issue = theIssue;
	self.comments = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[comments release], comments = nil;
	[issue release], issue = nil;
	
	[super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHIssueComments issue:'%@'>", issue];
}

- (void)loadComments {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseComments) withObject:nil];
}

- (void)parseComments {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *urlString = [NSString stringWithFormat:kIssueCommentsJSONFormat, issue.repository.owner, issue.repository.name, issue.num];
	NSURL *commentsURL = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:commentsURL];    
	[request start];
	NSError *parseError = nil;
    NSDictionary *resultDict = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:&parseError];
    NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in [resultDict objectForKey:@"comments"]) {
		GHIssueComment *comment = [[GHIssueComment alloc] initWithIssue:issue andDictionary:dict];
		[resources addObject:comment];
		[comment release];
	}
    id res = parseError ? (id)parseError : (id)resources;
	[self performSelectorOnMainThread:@selector(loadedComments:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)loadedComments:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotLoaded;
	} else {
		self.comments = theResult;
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

@end
