//
//  CommunicationModel.h
//  ConferenceSpeaker
//
//  Created by akru on 26/11/14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#ifndef ConferenceSpeaker_Protocol_h
#define ConferenceSpeaker_Protocol_h

#import "JSONModelLib.h"

@interface VoteSimpleRequest : JSONModel

@property (strong, nonatomic) NSString *request;
@property (strong, nonatomic) NSString *uuid;
@property (assign, nonatomic) BOOL answer;

@end

@interface VoteCustomRequest : JSONModel

@property (strong, nonatomic) NSString *request;
@property (strong, nonatomic) NSString *uuid;
@property (assign, nonatomic) int answer;

@end

@interface RegistrationRequest : JSONModel

@property (strong, nonatomic) NSString *request;
@property (strong, nonatomic) NSDictionary *user;

@end

#endif
