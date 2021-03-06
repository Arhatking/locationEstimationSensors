function [isInside, Estimatedcoord_density]=findminimumRSS(RSS_insidetriangle, RSS_outsidetriangle, RSSAnchorsTarget,i,Method)
%Format of RSS_insidetriangle=RSS_insidetriangle[Anchor1 Anchor2 Anchor3 Gridpoint RSSxAnchor1 RSSxAnchor2 RSSxAnchor3]
%Only for congruence with RSS_insidetriangle
if(isempty(RSS_insidetriangle)==1)
    Deviationsforinside=[];

end
if(isempty(RSS_insidetriangle)==0)
    [RSSinsidesizex y]=size(RSS_insidetriangle);
    RSSAnchorsTargetm=repmat(RSSAnchorsTarget,RSSinsidesizex,1);
    %Obtain RMSE between RSS inside of the triangle and the RSS of the
    %target node (all RSS are evaluated w/ respect to the anchors)
    Deviationsforinside=[sqrt((RSS_insidetriangle(:,6)-RSSAnchorsTargetm(:,1)).^2+(RSS_insidetriangle(:,7)-RSSAnchorsTargetm(:,2)).^2+(RSS_insidetriangle(:,8)-RSSAnchorsTargetm(:,3)).^2) RSS_insidetriangle(:,4:5)];
    %Search for min in insidecases
    Mininside=min(Deviationsforinside(:,1));
end

%Only for congruence with RSS_outsidetriangle
[RSSoutsidesizex y]=size(RSS_outsidetriangle);
RSSAnchorsTargetm=repmat(RSSAnchorsTarget,RSSoutsidesizex,1);
%Obtain RMSE between RSS outside of the triangle and the RSS of the
%target node (all RSS are evaluated w/ respect to the anchors)
Deviationsforoutside=[sqrt((RSS_outsidetriangle(:,6)-RSSAnchorsTargetm(:,1)).^2+(RSS_outsidetriangle(:,7)-RSSAnchorsTargetm(:,2)).^2+(RSS_outsidetriangle(:,8)-RSSAnchorsTargetm(:,3)).^2) RSS_outsidetriangle(:,4:5)];
%Search for min in outsidecases
Minoutside=min(Deviationsforoutside(:,1));

if(isempty(RSS_insidetriangle)==1)
    %In the case of an empty RSS_insidetriangle MIN=Minoutside
    MIN=Minoutside;
end

if(isempty(RSS_insidetriangle)==0)
    %We have RSS_insidetriangle and RSS_outsidetriangle no-empty
    if (Mininside < Minoutside)
            isInside=1;
        else
            isInside=0;
    end
else
    %We do not have inside RSS cases, therefore the point is outside 
    isInside=0;
end

%METHOD OF 1 MINIMUM (NNSS), NEAREST NEIGHBORS IN SIGNAL SPACE, K=1. (SEE
%PAPER OF RADAR)
if (Method==1)
    %Estimate the position of the node
    if(isempty(RSS_insidetriangle)==0)
            MIN=min(Mininside,Minoutside);
            if MIN==Mininside
                %In which row of deviationsforinside we find the MIN?
                 Matchtosearch=find(Deviationsforinside(:,1)==MIN);
                %Use the row found in RSS_insidetriangle to retrieve the coordinates of
                %the gridpoint (columns 4 and 5)
                Estimatedcoord_density=[i RSS_insidetriangle(Matchtosearch(1),4:5)];
            else
                %In which row of deviationsforoutside we find the MIN?
                Matchtosearch=find(Deviationsforoutside(:,1)==MIN);
                %Use the row found in RSS_outsidetriangle to retrieve the coordinates of
                %the gridpoint (columns 4 and 5)
                Estimatedcoord_density=[i RSS_outsidetriangle(Matchtosearch(1),4:5)];
            end
    else
            %Case that RSS_insidetriangle is empty
            Matchtosearch=find(Deviationsforoutside(:,1)==MIN);
            %Use the row found in RSS_outsidetriangle to retrieve the coordinates of
            %the gridpoint (columns 4 and 5)
            Estimatedcoord_density=[i RSS_outsidetriangle(Matchtosearch(1),4:5)];
    end
end
%METHOD OF 2 MINIMUM (NNSS), NEAREST NEIGHBORS IN SIGNAL SPACE, K=n. (SEE
%PAPER OF RADAR)
if (Method==2)
    K=200;
    %First we sort the elements in ascending order according to COL 1
    %We sort the rows according to COL1 in ascending order
    Devtot=[Deviationsforoutside; Deviationsforinside];
    Devtot=sortrows(Devtot,1);
    %We take the first K elements (which in this case belong to the K less
    %values)
    Estimatedcoord_density=[i mean(Devtot(1:K,2)) mean(Devtot(1:K,3))];
end

