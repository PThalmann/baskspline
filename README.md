# Overview
Extension of the package "baskexact" ( https://github.com/lbau7/baskexact ) to allow for weighting via monotonic splines.

# Installation

Installation of the package is done via devtools:
```
# install.packages("devtools")
devtools::install_github("https://github.com/PThalmann/baskspline")
```

# Usage

For a detailed explanation of all features, refer to the documentation of 
the parent-package, "baskexact" ( https://github.com/lbau7/baskexact ).

## Additions:

```
library(baskspline)
design <- setupOneStageBasket(k = 3, shape1 = 1, shape2 = 1, p0 = 0.2)
```

```
toer(
  design = design,
  p1 = NULL,
  n = 15,
  lambda = 0.99,
  weight_fun = weights_spline,
  weight_params = list(
  diffknots = ,
  weightknots = ,
  splinemethod = "monoH.FC",
  clamplim = c(0, 1),
  ),
  results = "group"
)
```

The usage of `weight_spline` as the weighting function (`weight_fun`) enables
the weighting via monotonic splines.
The list of arguments passed to `weight_params` contains:

  -`diffknots`
  
  -`weightknots`
  
  -`splinemethod`
  
  -`clamplim`
  
The vector passed to `diffknots` specifies the locations. `diffknots` is 
refers to the difference between two baskets, ranging from 0 to 1.
The vector passed to `weightknots` specifies the weighting associated with the
defined `diffknots`.
The `splinemethod` defines the method used for interpolation between the knots
determined in `diffknots` and `weightknots`. As this input refers to the 
arguments of the function `base::splinefun`, the corresponding documentation
should be examined for further details.
`clamplim` is a vector of length two defining lower and upper bounds of the 
resulting weights, with the first element of the vector defining the lower 
bound and the last element defining the upper bound.
Clamping is always applied and restricts the resulting weights, as the applied
interpolation could result in weights out side the range of 0 to 1. These are,
however, not sensible in the context of weighting, as weights have to be convex.
Therefore, every resulting weight below 0 is set to 0 and every resulting 
weight above 1 is set to 1.
These clamping limits can be modified to suit specific needs, but it is advised
to exercise caution.
  
# Examples

```
design <- setupOneStageBasket(k = 3, p0 = 0.2)

toer(design, 
n = 15, 
lambda = 0.99, 
weight_fun = weights_spline,
weight_params = list(
  diffknots = c(1, 0.5, 0),
  weightknots = c(0, 0, 1),
  splinemethod = "monoH.FC",
  clamplim = c(0, 1)),
results = "group"
)
```

