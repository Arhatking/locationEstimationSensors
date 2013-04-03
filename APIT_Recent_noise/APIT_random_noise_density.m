function [Error_total, Error, Error_2, Error_mult, size_EstimatedCoordinates_row, size_EstimatedCoordinatesr_row, size_Estimatedmult_row, AH, ND]=APIT_random_noise_density
% needed
tic
%Deploy xx nodes with the same configuration that Neal Patwari made his
%experiments.
%Declare global variables in order to manipulate the code faster
global M N Res DOIv
%Define number of blindfolded devices
M=30;
%Define number of referene devices
N=3;
%Define resolution of the grid (for the recorder RSS measurements). Side of
%the grid area
Res=0.1;
%Index for DOI in the RIM Model (noise)
DOIv=0.3;

[X, Indices, Radio_approx]=deploy_nodes_random_def();
%Compute TrueDist and matrix for the Grid
[TrueDist, H]=matrixDist_and_Grid(X);
%Characterization of the medium (Use of the RIM model)
[Pij, RSS_noise, dth_RSS_Neighborhood]=empmodel_DOI(X, TrueDist);
%Define connectivity and neighbors between nodes in the graph
[AH, ND, Neighborhood,Audibleanchors]=connectivity_DOI(X, Indices, RSS_noise, dth_RSS_Neighborhood);
%Function which computes the triangles and decide if a node is inside of a
%triangle computing the density of RSS. It also provides the estimated coordinates through RF profiling (similar than RADAR) [Function in test]
[TableNodesOutside, TableNodesInside, Estimatedcoord_density, Endprogram]=APITtest_surface(X,Audibleanchors,RSS_noise,Neighborhood,Indices,H);
%Function to make the aggregation
if(Endprogram==0)
    %Plot the estimated coordinates after finding the minimum RSS
    %(comparing observed set of RSS and the recorded RSS through the grid)
    plot(Estimatedcoord_density(:,2),Estimatedcoord_density(:,3),'s','MarkerEdgeColor','k','MarkerFaceColor','g');
    labels = num2str(Estimatedcoord_density(:,1));
    %For labelling each sensor
    text(Estimatedcoord_density(:,2)+.06,Estimatedcoord_density(:,3),labels,'Color','r');
    
    %Function to draw lines between the true and the estimated position
    Xnodes=drawlinesrealestpos(Estimatedcoord_density,X);
    %Function to compute the RMSE for estimated positions
    Error=RMSE(Xnodes,Estimatedcoord_density);
    fprintf(1,'--RMSE_est: %f.\n',Error);
    [size_EstimatedCoordinates_row y]=size(Estimatedcoord_density);
    %In case of one APIT iteration (computation of one set of estimated
    %nodes)
    Error_total=Error;
    Error_2=0;
    size_EstimatedCoordinatesr_row=0;
    size_Estimatedmult_row=0;
    Error_mult=0;
else
    Error_total=0;
    Error=0;
    Error_2=0;
    size_EstimatedCoordinates_row=0;
    size_EstimatedCoordinatesr_row=0;
    size_Estimatedmult_row=0;
    toc
    return;
end
