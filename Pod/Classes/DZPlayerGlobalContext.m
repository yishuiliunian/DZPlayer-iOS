//
//  DZPlayerGlobalContext.m
//  Pods
//
//  Created by baidu on 2016/12/20.
//
//

#import "DZPlayerGlobalContext.h"
#import "avcodec.h"
static int DZGlobalContextInitialed = NO;

void DZPlayerGlobalContextInit()
{
    if (DZGlobalContextInitialed) {
        return;
    }
    avcodec_register_all();
}



