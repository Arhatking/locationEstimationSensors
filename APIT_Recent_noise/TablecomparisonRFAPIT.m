function [ErrorAPITt ErrorRFt PercErrorAPIT PercErrorRF]=TablecomparisonRFAPIT
% needed
tic
%Deploy xx nodes with the same configuration that Neal Patwari made his
%experiments.
%Declare global variables in order to manipulate the code faster
global M N Res DOIv
%Define number of blindfolded devices
M=80;
%Define number of referene devices
N=40;
%Define resolution of the grid
Res=0.5;
%Index for DOI in the RIM Model (noise)
DOIv=0.1;

[X, Indices, Radio_approx]=deploy_nodes_random_def();
%Compute TrueDist and matrix for the Grid
[TrueDist, H]=matrixDist_and_Grid(X);
%Characterization of the medium (Use of the RIM model)
[Pij, RSS_noise, dth_RSS_Neighborhood]=empmodel_DOI(X, TrueDist);
%Define connectivity and neighbors between nodes in the graph
[AH, ND, Neighborhood,Audibleanchors]=connectivity_DOI(X, Indices, RSS_noise, dth_RSS_Neighborhood);
%Function for drawing triangles
[TableNodesOutside, TableNodesOutsidetempo, TableNodesInside, Endprogram]=drawtrianglescomparetables(X,Audibleanchors,RSS_noise,Neighborhood,Indices);
%Function which computes the triangles and decide if a node is inside of a
%triangle computing the density of RSS. [Function in test]
%if(isempty(TableNodesInside)==0)
%    fprintf(1,'NOOOOOOOOOOOOOOOOO ESTA VACIO!!!!!!!!!!!!11111');
%    pause(5);
%end
[TableNodesOutsideSurf, TableNodesInsideSurf, Estimatedcoord_density,  InOut_realinside, InOut_realoutside,  Endprogram]=APITtest_surface(X,Audibleanchors,RSS_noise,Neighborhood,Indices,H,dth_RSS_Neighborhood);
%Function to count the errors between TableNodes using RF profile and APIT
%test
[ErrorAPITt ErrorRFt PercErrorAPIT PercErrorRF]=Errorsintables(InOut_realinside, InOut_realoutside, TableNodesInside, TableNodesOutsidetempo, TableNodesInsideSurf, TableNodesOutsideSurf);
%toc