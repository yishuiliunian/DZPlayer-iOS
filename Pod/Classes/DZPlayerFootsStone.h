//
//  DZPlayerFootsStone.h
//  Pods
//
//  Created by baidu on 2016/12/20.
//
//

#import <Foundation/Foundation.h>

@interface DZPlayerFootsStone : NSObject
@property (nonatomic, strong, readonly) NSURL* url;
- (instancetype) init UNAVAILABLE_ATTRIBUTE;
- (instancetype) initWithURL:(NSURL*)url NS_DESIGNATED_INITIALIZER;
@end
