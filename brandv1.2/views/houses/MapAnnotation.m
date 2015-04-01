//
//  MapAnnotation.m
//  brandv1.2
//
//  Created by Apple on 15/3/3.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation
-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle subTitle:(NSString *)paramSubtitle{
    self = [super init];
    if(self != nil)
    {
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubtitle;
    }
    return self;
}
-(void)setId:(NSString *)id{

    _id = id;
}
@end