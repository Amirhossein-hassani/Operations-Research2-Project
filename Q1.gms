Sets
    j /1*5/
    K /1*12/
    L /1*10/
    M /1*5/;

Variables

    S1(j)   Number of Start-up of type 1 generators
    S2(j)   Number of Start-up of type 2 generators
    S3(j)   Number of Start-up of type 3 generators
    x1(K, j) Output level of type 1 generators
    x2(L, j) Output level of type 2 generators
    x3(M, j) Output level of type 3 generators
    y1(K, j) Binary variable for type 1 generators
    y2(L, j) Binary variable for type 2 generators
    y3(M, j) Binary variable for type 3 generators
    ObjVar;

Positive Variable x1, x2, x3;
Binary Variable y1, y2, y3;
Integer Variable S1, S2, S3;

Parameters
          Demand(j) /1 15000, 2 30000, 3 25000, 4 40000, 5 27000/
          T(j)      /1 6, 2 3, 3 6, 4 3, 5 6/   ;

Scalar
    obj_coeff1, obj_coeff2, obj_coeff3;


obj_coeff1 = 2;
obj_coeff2 = 1.3;
obj_coeff3 = 3;

Equations
    PowerGenerationConstraint
    GeneratorOutputLimits1
    GeneratorOutputLimits2
    GeneratorOutputLimits3
    GeneratorOutputLimits4
    GeneratorOutputLimits5
    GeneratorOutputLimits6
    DemandAdjustmentConstraint
    StartUpConstraint1
    StartUpConstraint2
    StartUpConstraint3
    ObjectiveFunction;

PowerGenerationConstraint(j).. sum(K, x1(K, j)) + sum(L, x2(L, j)) + sum(M, x3(M, j)) =g= Demand(j);

GeneratorOutputLimits1(K, j).. 850*y1(K, j) =l= x1(K, j);
GeneratorOutputLimits2(K, j).. x1(K, j) =l= 2000*y1(K, j);

GeneratorOutputLimits3(L, j).. 1250*y2(L, j) =l= x2(L, j);
GeneratorOutputLimits4(L, j).. x2(L, j) =l= 1750*y2(L, j);

GeneratorOutputLimits5(M, j).. 1500*y3(M, j) =l= x3(M, j);
GeneratorOutputLimits6(M, j).. x3(M, j) =l= 4000*y3(M, j);

DemandAdjustmentConstraint(j).. 2000*sum(K, y1(K, j)) + 1750*sum(L, y2(L, j)) + 4000*sum(M, y3(M, j)) =g= 1.15*Demand(j);

StartUpConstraint1(j).. S1(j) =g= sum(K, y1(K, j) - y1(K, j-1));
StartUpConstraint2(j).. S2(j) =g= sum(L, y2(L, j) - y2(L, j-1));
StartUpConstraint3(j).. S3(j) =g= sum(M, y3(M, j) - y3(M, j-1));


ObjectiveFunction..
    ObjVar =e= sum(j, obj_coeff1 * (sum(K, x1(K, j) - 850*y1(K, j))) +
    obj_coeff2 * (sum(L, x2(L, j) - 1250*y2(L, j))) +
    obj_coeff3 * (sum(M, x3(M, j) - 1500*y3(M, j)))) +
    sum(j, 1000*sum(K, y1(K, j)*T(j)) + 2600*sum(L, y2(L, j)*T(j)) + 3000*sum(M, y3(M, j)*T(j))) +
    sum(j, 2000*S1(j) + 1000*S2(j) + 500*S3(j));




Model PowerGeneration /all/;

PowerGeneration.optCr = 0;

* Sensivity Analysis

$onecho > cplex.opt
*objrng all
*rhsrng all
$offecho
*PowerGeneration.optfile = 1;

* Solving the Problem

solve PowerGeneration minimizing ObjVar using mip;
display x1.l, x2.l, x3.l, y1.l, y2.l, y3.l, S1.l, S2.l, S3.l, ObjVar.l;