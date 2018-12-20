//
//  Header.h
//  GeometryFighter
//
//  Created by 김혁 on 19/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef Header_h
#define Header_h

#include <stdlib.h>

typedef enum
{
  box = 0,
  sphere,
  pyramid,
  torus,
  capsule,
  cylinder,
  cone,
  tube
} ShapeTypes;

static inline ShapeTypes
shapetypes_random(void)
{
  uint32_t r = arc4random_uniform(tube + 1);
  
  r = r % (tube + 1);
  
  return (ShapeTypes)r;
}
#endif /* Header_h */
