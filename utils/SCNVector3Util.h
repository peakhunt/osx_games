//
//  SCNVector3Util.h
//  Breaker
//
//  Created by 김혁 on 22/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef SCNVector3Util_h
#define SCNVector3Util_h

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

#include "math.h"

static inline SCNVector3
scnvector3_invert(SCNVector3 v)
{
  SCNVector3 ret = SCNVector3Make(v.x * -1, v.y * -1, v.z * -1);
  return ret;
}

static inline float
scnvector3_length(SCNVector3 v)
{
  return sqrtf((v.x * v.x) + (v.y * v.y) + (v.z * v.z));
}

static inline void
scnvector3_set_length(SCNVector3* v, float l)
{
  float pl = scnvector3_length(*v);
  
  // first make it a unit
  v->x /= pl;
  v->y /= pl;
  v->z /= pl;
  
  // apply new length
  v->x *= l;
  v->y *= l;
  v->z *= l;
}

static inline float
scnvector3_length_squared(SCNVector3 v)
{
  return (v.x * v.x) + (v.y * v.y) + (v.z * v.z);
}

static inline SCNVector3
scnvector3_unit(SCNVector3 v)
{
  float l = scnvector3_length(v);
  SCNVector3 ret;
  
  ret= SCNVector3Make(v.x/l, v.y/l, v.z/l);
  return ret;
}

static inline void
scnvector3_normalize(SCNVector3* v)
{
  float l = scnvector3_length(*v);
  
  v->x /= l;
  v->y /= l;
  v->z /= l;
}

static inline float
scnvector3_distance(SCNVector3 a, SCNVector3 b)
{
  SCNVector3 l = SCNVector3Make(a.x - b.x, a.y - b.y, a.z - b.z);
  
  return scnvector3_length(l);
}

static inline float
scnvector3_dot(SCNVector3 a, SCNVector3 b)
{
  return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
}

static inline SCNVector3
scnvector3_cross(SCNVector3 a, SCNVector3 b)
{
  return SCNVector3Make(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

static inline float
scnvector3_get_xy_angle(SCNVector3 v)
{
  return atan2(v.y, v.x);
}

static inline void
scnvector3_set_xy_angle(SCNVector3* v, float rad)
{
  float l = scnvector3_length(*v);
  
  v->x = cos(rad) * l;
  v->y = sin(rad) * l;
}

static inline float
scnvector3_get_xz_angle(SCNVector3 v)
{
  return atan2(v.z, v.x);
}

static inline void
scnvector3_set_xz_angle(SCNVector3* v, float rad)
{
  float l = scnvector3_length(*v);
  
  v->x = cos(rad) * l;
  v->z = sin(rad) * l;
}

static inline SCNVector3
scnvector3_add(SCNVector3 left, SCNVector3 right)
{
  SCNVector3 ret;
  
  ret.x = left.x + right.x;
  ret.y = left.y + right.y;
  ret.z = left.z + right.z;
  
  return ret;
}

static inline void
scnvector3_add_to_left(SCNVector3* left, SCNVector3 right)
{
  left->x += right.x;
  left->y += right.y;
  left->z += right.z;
}

static inline SCNVector3
scnvector3_sub(SCNVector3 left, SCNVector3 right)
{
  SCNVector3 ret;
  
  ret.x = left.x - right.x;
  ret.y = left.y - right.y;
  ret.z = left.z - right.z;
  
  return ret;
}

static inline void
scnvector3_sub_from_left(SCNVector3* left, SCNVector3 right)
{
  left->x -= right.x;
  left->y -= right.y;
  left->z -= right.z;
}

static inline SCNVector3
scnvector3_mul(SCNVector3 left, SCNVector3 right)
{
  SCNVector3 ret;
  
  ret.x = left.x * right.x;
  ret.y = left.y * right.y;
  ret.z = left.z * right.z;
  
  return ret;
}

static inline void
scnvector3_mul_to_left(SCNVector3* left, SCNVector3 right)
{
  left->x *= right.x;
  left->y *= right.y;
  left->z *= right.z;
}

static inline SCNVector3
scnvector3_mul_scalar(SCNVector3 left, float scalar)
{
  SCNVector3 ret;
  
  ret.x = left.x * scalar;
  ret.y = left.y * scalar;
  ret.z = left.z * scalar;
  
  return ret;
}

static inline void
scnvector3_mul_scalar_to_left(SCNVector3* left, float scalar)
{
  left->x *= scalar;
  left->y *= scalar;
  left->z *= scalar;
}

static inline SCNVector3
scnvector3_div(SCNVector3 left, SCNVector3 right)
{
  SCNVector3 ret;
  
  ret.x = left.x / right.x;
  ret.y = left.y / right.y;
  ret.z = left.z / right.z;
  
  return ret;
}

static inline void
scnvector3_div_by_right(SCNVector3* left, SCNVector3 right)
{
  left->x /= right.x;
  left->y /= right.y;
  left->z /= right.z;
}

static inline SCNVector3
scnvector3_div_by_scalar(SCNVector3 left, float scalar)
{
  SCNVector3 ret;
  
  ret.x = left.x / scalar;
  ret.y = left.y / scalar;
  ret.z = left.z / scalar;
  
  return ret;
}

static inline void
scnvector3_div_left_by_scalar(SCNVector3* left, float scalar)
{
  left->x /= scalar;
  left->y /= scalar;
  left->z /= scalar;
}

static inline SCNVector3
scnvector3_negate(SCNVector3 left)
{
  return scnvector3_mul_scalar(left, -1);
}

#endif /* SCNVector3Util_h */
