//
//  MapAnnotation.h
//  brandv1.2
//
//  Created by Apple on 15/3/3.
//  Copyright (c) 2015年 Apple. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>
//显示标注的经纬度
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
//标注的标题
@property (nonatomic,copy,readonly) NSString * title;
//标注的子标题
@property (nonatomic,copy,readonly) NSString * subtitle;

//标注的id
@property (nonatomic,copy) NSString * id;

-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramSubtitle;

@end