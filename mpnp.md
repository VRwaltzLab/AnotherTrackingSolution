# Multi-Camera Perspective N Point

## Problem Statement:
Given n 3D points with a static arrangement on the object rig.
And m 2D projections of those points onto c calibrated cameras where the cameras have a static arrangement on the camera rig,
Determine the relative pose of the object rig and the camera rig which can be represented as a 4 by 4 matrix: [R T; 0^T 1] where R is orthogornal.

## Reduction to small O(1) quadratic program:
### Formulation of problem:
For each projection p in homogenous 2D coordinates of a point q in homogeneous 3D coordinates,
seen by a camera with characteristics matrix K and 3by 4 pose matrix C, there exists a real constant s
such that this equation holds   sp = KC[R T; 0^T 1]q 
### Least square formulation
let C = [S b] with vector d = S^(-1)b and  v = S^(-1)K^(-1)p, 
Each projection's equation becomes sv =[R T]q + d , the squared error in this equation is:
 || (I-vv^T)[R T]q - (I-vv^T)(d)|| where I is the identity matrix for dimension 3 and the norm ||.|| is the euclidean norm
which can be made linear as :
 || (I-vv^T)(Ixq^T)vec([R T]) - (I-vv^T)(d) || where x is the kronecker product and vec turns a matrix into a vector row by row.
We can view this error to be minimized under the constraints that R is orthogonal as a sum of inner products.
### putting the optimization criteria into fixed form.
with w equaling 1 row of the 3m differences, and c being the corresponding constant.
Total_Error = Sum (<w^Tx-c, w^Tx-c> )
spreading out the inner product:
Total_Error = Sum ( <w^Tx,w^Tx> -2<c,w^Tx> + <c,c>)
writing it as matrix equations:
Total_Error = Sum ( x^Tww^Tx -2cw^Tx + c^2) 
and using linearity:
Total_Error = x^T(Sum(ww^T))x -2(Sum(cw))^Tx + (Sum(c^2)) 
and so we get a quadratic program with 6 constraints generated from R^TR = I and an optimization goal of minimizing Total Error.
This quadratic program has 12 variables, but by using final equation form for Total_error has a fixed number of constants regardless of the initial input size m or n.
So this derivation is a linear work O(m) reduction to a small quadratic program
## How to solve that quadratic program:
Many solvers exist. Which one is best for this problem is ...
