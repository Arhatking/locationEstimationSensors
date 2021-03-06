function [Pij, RSS_noise, dth_RSS_Neighborhood]=empmodel_DOI(X, TrueDist)
global M N DOIv

%Distance_threshold for RSS. This value is obtained from data of Calamari.
%We have to check out this threshold value.
dth_RSS_Neighborhood=1.5;

%Initialization of arrays
m=[];
thetar=[];
thetad=[];
thetadr=[];
Pairabovethr=[];
RSS_noise=[];

%X=a+(b-a)R
%R is a random number from the uniform dist. [0 1]
%X is going to be / [-1 1]
%X should be Weibull according to the paper of He. not uniform

%a=-1*ones(50*360,1); %M+N - We should generate with the same seed for the total of nodes
%b=ones(50*360,1); %M+N
%RAND=a+((b-a).*rand(50*360,1)); %Generates uniform dist [-1 1]

%From the paper of Tian He of the Weibull distribution
%X=alfa(-ln(1-R))^(1/beta), Formula obtained from the book of Simulation
%1.01 and 0.17 are values obtained from the Appendix dataset of the paper
%of RIM of Tian He.
beta=1.01*ones((M+N)*360,1); 
alfa=0.17*ones((M+N)*360,1); 
RANDt=rand((M+N)*360,1);
RAND=alfa.*((-log(1-RANDt)).^(1./beta));

Num_node=1;
%We are going to generate 360 values which belong to the different 360 i
%directions
%At the end of the for cycle we may have Kis for all the nodes of the
%network

%Generation of the Kis values according to formula (3) of the paper of RIM
%In this code we are missing to compute K values when i is not an integer.
K=zeros((M+N)*360,3); %M+N
%Format of K=K[Node K_Value Direction_in_degrees]

for i=1:((M+N)*360)
    if i==1 | mod(i,360)==1
        if i==360 %This belongs truly to i=359 (since i begins at 1)
            K(i,:)=[Num_node K(i-1,2)+(RAND(i,1)*DOIv) Grades];
        end
        if i~=360
            Grades=0;
            if i~=1
                Num_node=Num_node+1; %Increase the num_node since we are in another cycle
            end
            K(i,:)=[Num_node 1 Grades]; %Ki=1, i=1 (truly this value belongs to i=0)
            Grades=Grades+1;
        end
    else
       if mod(i,2)~=0
            K(i,:)=[Num_node K(i-1,2)+(RAND(i,1)*DOIv) Grades]; %Ki, for i~=1
            Grades=Grades+1;
       else
            K(i,:)=[Num_node K(i-1,2)-(RAND(i,1)*DOIv) Grades]; %Ki, for i~=1
            Grades=Grades+1;
       end
    end
end

%Q is the number of Quadrant. Here we compute the value of m's for each
%pair of nodes in the network
%1st Q [+ +] then nothing
%2nd Q [- +] then 180-(abs(res))
%3rd Q [- -] then 180 + res
%4th Q [+ -] then 360-(abs(res))

cont=1;
for i=1:(M+N)
    for j=1:(M+N)
        if i~=j
            %Format of matrix of m=[TargetNode Valueofm NoQuadrant]
                 %y's                 %x's
            if (X(i,2)-X(j,2))> 0 & (X(i,1)-X(j,1))> 0 %Ist Q
                m(cont,:)=[j (X(i,2)-X(j,2))/(X(i,1)-X(j,1)) 1 i];
            elseif (X(i,2)-X(j,2))> 0 & (X(i,1)-X(j,1))< 0 %2nd Q
                m(cont,:)=[j (X(i,2)-X(j,2))/(X(i,1)-X(j,1)) 2 i];
            elseif (X(i,2)-X(j,2))< 0 & (X(i,1)-X(j,1))< 0 %3rd Q
                m(cont,:)=[j (X(i,2)-X(j,2))/(X(i,1)-X(j,1)) 3 i];
            elseif (X(i,2)-X(j,2))< 0 & (X(i,1)-X(j,1))> 0 %4th Q
                m(cont,:)=[j (X(i,2)-X(j,2))/(X(i,1)-X(j,1)) 4 i];
            end
                cont=cont+1;
        end
    end
end


%Format of thetar=[Target_Node Degrees_in_radians]
thetar(:,1)=m(:,1); %Copy the first column of m "Target_Nod" to the array of angles in radians
thetar(:,2)=atan(m(:,2)); %Degrees in radians

%Format of thetad=[Target_Node Degrees_in_grades Num_Quadrant]
thetad(:,1)=thetar(:,1); %Copy the first column (Target_Node) to the array of angles in degrees
thetad(:,2)=(thetar(:,2).*180)./pi;
thetad(:,3)=m(:,3); %Copy the third column (Num_Q) to the array of angles in degrees

[q r]=size(thetad);

%Format of thetadr=[Target_Node Degrees_in_grades(rounded) Node_compared]
thetadr(:,1)=m(:,1);
for i=1:q
    if (thetad(i,3)==1)
        thetadr(i,2)=round(thetad(i,2));
        %In order to avoid 360 degrees that are equivalent to 0 degrees,
        %since K works from 0 to 359 degrees
        if thetadr(i,2)==360
            thetadr(i,2)=0;
        end
    elseif (thetad(i,3)==2)
        thetadr(i,2)=round(180-abs(thetad(i,2)));
        if thetadr(i,2)==360
            thetadr(i,2)=0;
        end
    elseif (thetad(i,3)==3)
        thetadr(i,2)=round(180+thetad(i,2));
        if thetadr(i,2)==360
            thetadr(i,2)=0;
        end
    elseif (thetad(i,3)==4)
        thetadr(i,2)=round(360-abs(thetad(i,2)));
        if thetadr(i,2)==360
            thetadr(i,2)=0;
        end
    end
end
thetadr(:,3)=m(:,4);

%Reference distance
di=0.1; %[m]
%Reference power at do
P0=-37.466; %[dBm]
%Propagation exponent
np=2.3;
%Compute the matrix of the mean power for every pair [i,j] of nodes. 
Pij=10*np*log10(TrueDist.*(1/di));
[me n]=size(TrueDist);
cont=1;
for i=1:me
    for j=1:me
        if TrueDist(i,j)<=di %if the distance / two sensors is equal or less that 1 m
            Pij(i,j)=0; %in order to not get power levels that do not agree with the model since it is valid just for P where d>1m
        end
        %-> ADDED CODE
        if TrueDist(i,j)>=dth_RSS_Neighborhood;
           Pairabovethr(cont,:)=[i j]; 
           cont=cont+1;
        end
    end
end
cont=1;
%Compute RSS considering Kis, the respective radius and angle i for each node of the
%network
[q r]=size(thetadr);
for i=1:q
%Format of RSS_noise=[TargetNode OtherNodeoftheNtwk RSS=Pt-DOIAdj TrueDist(i,j)]
%Where DOIAdj=Pathloss*Ki. Here we assume Pathloss to be gaussian, true?
%Formula (2) in the paper of RIM fading is considered. However, for
%simplicity fading is not considered in the environment.
                Angle_row=thetadr(i,2);
                Target_node=thetadr(i,1);
                Node_compared=thetadr(i,3);
                %Always match should be 1 x 1
                Match=find(K(:,3)==Angle_row & K(:,1)==Target_node);
                %Avoid those pair of nodes which TrueDist is above the
                %threshold
                if(isempty(Pairabovethr)==0)
                           Match_thr=find(Pairabovethr(:,1)==Target_node & Pairabovethr(:,2)==Node_compared); 
                else
                           Match_thr=[];
                end
                %Match_thr should be empty        -->in order to consider the nodes
                %and Match should be not empty
                if(isempty(Match)==0) & (isempty(Match_thr)==1)
                                                 %Obtain the respective Ki
                      RSS_noise(cont,:)=[Target_node Node_compared P0-(Pij(Target_node,Node_compared)*K(Match,2)) TrueDist(Target_node, Node_compared)];
                      cont=cont+1;
                end
end




