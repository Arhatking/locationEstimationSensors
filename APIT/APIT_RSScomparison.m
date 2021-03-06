tic
%Declare global variables in order to manipulate the code faster
global M N Res 
%Define number of blindfolded devices
M=50;
%Define number of referene devices
N=30;
%Define resolution of the grid
Res=0.5; %0.1Dist_Neighborhood
%[X, Indices]=deploy_nodes_random();
%Compute TrueDist and matrix for the Grid
%[TrueDist, H]=matrixDist_and_Grid(X);
%Define connectivity and neighbors between nodes in the graph
%[AH, ND, Neighborhood,Audibleanchors]=connectivity_ANR(X,Indices,TrueDist);
%Characterization of the medium
%Pij=empmodel(TrueDist);
%Function that make a new test in order to predict if a targetnode is
%inside or outside of a triangle
[TableNodesInside TableNodesOutside InOut_testinside InOut_testoutside  InOut_test InOut_realinside InOut_realoutside InOut_real Matches NoMatches]=RSScomparison(X, Indices, Audibleanchors,Neighborhood, Pij);
%Function for drawing triangles
[InsideorOutside, TableNodesOutside, TableNodesInside, TableNodesOutsidetempo, Nodeswecannotestimate]=drawtriangles_fst(X,Audibleanchors,Pij,Neighborhood,Indices);
%We compare Arrays
[m n]=size(InOut_realinside);
[o p]=size(TableNodesInside);
Matches_realtest_APITinside=0;
for i=1:m
    for j=1:o
        if InOut_realinside(i,:)==TableNodesInside(j,:)
            Matches_realtest_APITinside=Matches_realtest_APITinside+1;
        end
    end
end
[m n]=size(InOut_realoutside);
[o p]=size(TableNodesOutside);
Matches_realtest_APIToutside=0;
for i=1:m
    for j=1:o
        if InOut_realoutside(i,:)==TableNodesOutside(j,:)
            Matches_realtest_APIToutside=Matches_realtest_APIToutside+1;
        end
    end
end
%--
[m n]=size(InOut_realinside);
[o p]=size(InOut_testinside);
Matches_mytest_APITinside=0;
for i=1:m
    for j=1:o
        if InOut_realinside(i,:)==InOut_testinside(j,:)
            Matches_mytest_APITinside=Matches_mytest_APITinside+1;
        end
    end
end
[m n]=size(InOut_realoutside);
[o p]=size(InOut_testoutside);
Matches_mytest_APIToutside=0;
for i=1:m
    for j=1:o
        if InOut_realoutside(i,:)==InOut_testoutside(j,:)
            Matches_mytest_APIToutside=Matches_mytest_APIToutside+1;
        end
    end
end
