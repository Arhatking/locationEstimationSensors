function [AH, ND, Neighborhood,Audibleanchors]=connectivity_DOI(X,Indices, RSS_noise, dth_RSS_Neighborhood)
global M N Res 
Neighborhood=[];
Audibleanchors=[];

%RSS_noise=[TargetNode Nodetocompare RSS+noise]
%ANR defines the ratio between the distance of the beacon (Dist_Anchor) and the distance
%of the radio of a regular node (Dist_Neighborhood)
ANR= 1;

%We should simulate a value of RSS threshold in order to succesfully decode
%packets
%RSS_Neighborhood=-101; %Value in dBm
%RSS_Anchor=ANR*RSS_Neighborhood;

%We can take that further than a threshold distance there is no RSS at all.
RSS_Anchor=ANR*dth_RSS_Neighborhood;

%Counters
aux=1;
aux2=1;
cont=1;
cont2=1;

for x=1:(M+N) %M+N
    for y=1:(M+N) %M+N
       Node1=x; 
       Node2=y;
       %Procedure to define the number of AH (Anchors Heard) w/ANR
       %Take the TargetNode and Node_compared from the RSS table. 
       Match=find(RSS_noise(:,1)==x & RSS_noise(:,2)==y);
       if (isempty(Match)==0) 
            %if (RSS_noise(Match,3)>RSS_Anchor)   %CODED DELETED -> 04/04
            if (RSS_noise(Match,4)<RSS_Anchor)    %RSS_noise(Match,4) points to TrueDist(i,j) ADDED CODE-> 04/04
                %Node2 == Number of Anchor Anchor
                %Node1 == Number of TargetNode
                %If the matrix is empty (if 1) when trying to find Node1 means
                %that it is not an Anchor and it is a TargetNode
                %If the matrix is not empty (if 0) when trying to find Node2
                %means that is is an Anchor
                if ((isempty(find(Indices==Node2))==0) & (isempty(find(Indices==Node1))==1))                          %Node2 == 1 | Node2 == 11 | Node2 == 4 | Node2 == 15 | Node2==14 | Node2==28 | Node2 == 9 | Node2 == 7 | Node2 == 20 | Node2 == 30 | Node2 == 26 | Node2 == 29
                    fprintf(1,'--Target node %d has Anchor %d as an audible one.\n',Node1,Node2);
                    %Audibleanchors has the following format:
                    %Target node -- Audible anchor
                    %In order to form a triangle then:
                    %[1 a]
                    %[1 b]
                    %[1 c]
                    %Audibleanchors=Audibleanchors[TargetNode AudibleAnchor]
                    Audibleanchors(aux,:)=[Node1 Node2]; %Useful in order to consider which Anchors are listened for a Target Node
                    aux=aux+1;
                end
            end
            %Neighborhood has the following format: 
            %Target node -- Neighbor within a radius of 4.57
            %e.g. 1-4
            %     1-11
            %     1-23
            %     1-33
            %     2-3
            %     2-7
            %     2-39
       end
       %Procedure to define the Neighborhood with Dist_Neighborhood
       if (isempty(Match)==0) %we do not consider an if after this if because it is supposed that all nodes which TrueDistances are above RSS_Neighborhood (threshold) have already been filtered in empmodel_DOI
          % if (RSS_noise(Match,3)>RSS_Neighborhood) %CODE DELETED 04/04 
                Neighborhood(aux2,:)=[Node1 Node2];
                % Draw a line between two nodes if they are connected (i.e.
                % interdistance is less than the value of the threshold).
                % line([X(Node1,1) X(Node2,1)],[X(Node1,2) X(Node2,2)],'Color','g','LineStyle','--');
                aux2=aux2+1;
         %  end
       end
    end
    %To compute the number of Anchors per TargetNode (i.e. Node1)
    if (isempty(Audibleanchors)==0) & (isempty(find(Indices==Node1))==1)
         numbera=find(Audibleanchors(:,1)==Node1);
         [Number_Anchors a]=size(numbera); %Number_Anchors contains the number of anchors per TargetNode
         TargetNode_NumAnchors(cont,:)=Number_Anchors;
         cont=cont+1;
    end
    if (isempty(Neighborhood)==0) 
        numbern=find(Neighborhood(:,1)==Node1);
        [Number_Neighbors b]=size(numbern);
        TargetNode_NumNeighbors(cont2,:)=Number_Neighbors;
        cont2=cont2+1;
    end
   %To compute the number of Anchors per  (i.e. Node1)
    %CODE CHANGED MAY 30th
    %if (isempty(Audibleanchors)==0) & (isempty(find(Indices==Node1))==1)
    if (isempty(Audibleanchors)==0)   
         numbera=[];
         numbera=find(Audibleanchors(:,1)==Node1);
         if(isempty(numbera)==0)
             [Number_Anchors a]=size(numbera); %Number_Anchors contains the number of anchors per TargetNode
             TargetNode_NumAnchors(cont,:)=Number_Anchors;
             cont=cont+1;
         end
    end
    if (isempty(Neighborhood)==0)
        numbern=[];
        numbern=find(Neighborhood(:,1)==Node1);
        if(isempty(numbern)==0)
            [Number_Neighbors b]=size(numbern);
            TargetNode_NumNeighbors(cont2,:)=Number_Neighbors;
            cont2=cont2+1;
        end
    end
end

%Compute the average number of Anchors and Neighbors (i.e. ND and AH)
%[m n]=size(TargetNode_NumAnchors);
avg=sum(TargetNode_NumAnchors)/(M+N);
%Anchor heard
AH=avg;
fprintf(1,'--AH: Anchor Heard= %f\n',avg); %tnode

[m n]=size(TargetNode_NumNeighbors);
avg=sum(TargetNode_NumNeighbors)/m;
%Node density
ND=avg;
fprintf(1,'--ND: Node Density = %f\n',avg);