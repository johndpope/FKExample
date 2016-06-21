//
//  RRNode.h
//
//  Copyright (c) 2016 HelpURock. All rights reserved.
//
//  This module implements rendering logic for sprite kit that
//  reduces rendering memory requirements.

#import <SpriteKit/SpriteKit.h>

@class RRTexture;

@interface RRNode : NSObject

// The makeSpriteNode API creates a SKSpriteNode that joins
// a render node to the compressed texture representation.

+ (SKSpriteNode*) makeSpriteNode:(SKView*)skView
                         texture:(RRTexture*)texture;

// Update the texture and shader objects associated with a Node

+ (BOOL) updateSpriteNode:(SKView*)skView
                  texture:(RRTexture*)texture
                     node:(SKSpriteNode*)node;

@end
