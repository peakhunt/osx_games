//
//  random_util.c
//  GeometryFighter
//
//  Created by 김혁 on 19/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "random_util.h"

int
int_random(int min, int max)
{
  return (int)(arc4random_uniform((uint32_t)(max - min + 1))) + min;
}

double
double_random(double min, double max)
{
  double r64 = (double)arc4random() / (double)UINT32_MAX;
  
  return (r64 * (max - min)) + min;
}

float
float_random(float min, float max)
{
  float r32 = (float)arc4random() / (float)UINT32_MAX;
  
  return (r32 * (max - min)) + min;
}

float
convert_to_radians(float angle)
{
  return angle * (M_PI / 180);
}
