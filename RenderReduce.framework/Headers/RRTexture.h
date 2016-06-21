//
//  RRTexture.h
//
//  Copyright (c) 2016 HelpURock. All rights reserved.
//
//  This module holds instance references to an already encoded
//  image texture. The caller creates an instance of

#import <SpriteKit/SpriteKit.h>

@interface RRTexture : NSObject

// size indicate the original texture width and height in pixels

@property (nonatomic, assign) CGSize pixelSize;

// texture size in points

@property (nonatomic, assign) CGSize pointSize;

// adler32 checksum for input pixels

@property (nonatomic, assign) uint32_t adler32;

// SpriteKit texture object that contains the compressed texture

@property (nonatomic, retain) SKTexture *skTexture;

// SpriteKit shader instance compiled after compressed texture is generated

@property (nonatomic, retain) SKShader *shader;

// Encode time options

@property (nonatomic, copy) NSDictionary *options;

// Encode a compressed texture as a NSData and prepare a
// compiled texture shader object.

+ (RRTexture*) encodeTexture:(NSDictionary*)options
                     results:(NSMutableDictionary*)results;

// Adler32 checksum

+ (uint32_t) adlerForData:(NSData*)data;

@end
