//
//  Lattice.m
//  Lattice
//
//  Created by Samuel Warmuth on 9/24/12.
//  Copyright (c) 2012 Sam Warmuth. All rights reserved.
//

#import "Post.h"
#import "Annotation.h"
#import "RichText.h"
#import "User.h"
#import "SWAppDelegate.h"
#import "SWHelpers.h"


@implementation Post

@dynamic created_at;
@dynamic id;
@dynamic num_replies;
@dynamic int_id;
@dynamic thread_id;
@dynamic you_reposted;
@dynamic you_starred;
@dynamic annotations;
@dynamic replies;
@dynamic reply_to;
@dynamic repost_of;
@dynamic reposts;
@dynamic text;
@dynamic user;


+ (NSManagedObject *)objectForID:(NSString *)id
{
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    NSError *error;
    NSFetchRequest *existsFetch = [[NSFetchRequest alloc] init];
    [existsFetch setEntity:[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext]];
    [existsFetch setFetchLimit:1];
    [existsFetch setPredicate:[NSPredicate predicateWithFormat:@"id == %@", id]];
    return [[managedObjectContext executeFetchRequest:existsFetch error:&error] lastObject];
}

+ (NSMutableArray *)createOrUpdatePostsFromArray:(NSMutableArray *)array
{
    NSMutableArray *posts = [NSMutableArray new];
    for (NSDictionary *dictionary in array) {
        [posts addObject:[self createOrUpdatePostFromDictionary:dictionary]];
    }
    return posts;
}

+ (Post *)createOrUpdatePostFromDictionary:(NSDictionary *)dictionary
{
    KLog(@"Fire");
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

    
    Post *post = (Post *)[self objectForID:[dictionary objectForKey:@"id"]];
    if (!post) post = (Post *)[NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:managedObjectContext];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    post.id = [dictionary objectForKey:@"id"];
    post.int_id = [formatter numberFromString:[dictionary objectForKey:@"id"]];
    post.num_replies = [dictionary objectForKey:@"num_replies"];
    post.thread_id = [dictionary objectForKey:@"thread_id"];
    post.you_reposted = [dictionary objectForKey:@"you_reposted"];
    post.you_starred = [dictionary objectForKey:@"you_starred"];
    
    
    post.created_at = [SWHelpers dateFromRailsDateString:[dictionary objectForKey:@"created_at"]];
    
    post.text = [RichText createOrUpdateRichTextFromDictionary:dictionary];
    post.user = [User createOrUpdateUserFromDictionary:[dictionary objectForKey:@"user"]];
    
    if ([dictionary objectForKey:@"repost_of"]){
        post.repost_of = [self createOrUpdatePostFromDictionary:[dictionary objectForKey:@"repost_of"]];
    }
    
    post.annotations = [Annotation createOrUpdateAnnotationsFromArray:[dictionary objectForKey:@"annotations"]];

    return post;
}

@end
