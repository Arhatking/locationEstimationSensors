function [checkinv, Estimatedcoordinates_mult]=multilateration_noise(Estimatedcoordinates, Audibleanchors, RSS_noise, Indices, X)

%Estimatedcoordinates are the initial positions, we are going to use
%Newton-Raphson/least-squares within the paper of Localization of Sensors
%First we are going to use TrueDist, after we have to consider an approach
%to consider noisy measurements.

%A refers to the anchor
%so to the initial point
%we should need the 
%D_A1 distance from A1 to i
Estimatedcoordinates_mult=[];
Num_iteraciones=0;
np=2.3;
do=1;
dev_standard=3.92;
P0=-37.466;
counter=1;
checkinv=[];

global M N DOIv
epsilon=0.01; %accuracy between estimated coordinates and true coordinates, in order to break the cycle
cont=1;
flag=0;

beta=1.01*ones((M+N)*360,1); 
alfa=0.17*ones((M+N)*360,1); 
RANDt=rand((M+N)*360,1);
RAND=alfa.*((-log(1-RANDt)).^(1./beta));
%Generation of the Kis values according to formula (3) of the paper of RIM
%In this code we are missing to compute K values when i is not an integer.
K=zeros((M+N)*360,3); %M+N
%Format of K=K[Node K_Value Direction_in_degrees]
Num_node=1;

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

for h=1:(M+N)
    Findtarget=[];
    Findindex=[];
    Coordinatesanchor=[];
    Nodesforanchor=[];
    Aiter=[]; %initialization of arrays
    b=[];
    Weights=[];
    Dist=[];
    Pij_est=[];
    ranges_noise=[];
    Findtarget=find(Estimatedcoordinates(:,1)==h);
    Findindex=find(Indices(:,1)==h); %if index is found->Findindex is nonempty,it should be empty so it is a TargetNode
    E_So=1000; %dummies
    E_Soprime=1;
    
    if (isempty(Findtarget)==0) & (isempty(Findindex)==1) 
           fprintf(1,'--Refining position of node %d\n',h);
           So=Estimatedcoordinates(Findtarget(1),2:3); %retrieves {x,y} from the estimated node to be considered as a seed.
           Saux=So; %we use Saux in case we do not find another better approx
           Nodesforanchor=find(Audibleanchors(:,1)==h); %Search for the rows for the particular target node, from the rows we can obtain the anchors.
           [m n]=size(Nodesforanchor);
           if m>=3 %Means that a target node has three or more anchors, thus multilateration has a sense and we can refine the position of the node, otherwise, we can not refine the position of the node.
              %Create weights for the process of multilateration, variance of
               %the distance is multiplicative
               for j=1:m
                   %Vector for the target node
                   V1=complex(X(h,1),X(h,2));
                   %Vector for the anchor
                   V2=complex(X(Audibleanchors(Nodesforanchor(j),2),1),X(Audibleanchors(Nodesforanchor(j),2),2));
                   %Vector that points to the target node
                   V=V1-V2;
                   RE=real(V);
                   IM=imag(V);
                   MagV1=abs(V);
                   if RE>0 & IM >0 %1Q
                   ANGLE=angledim(angle(V),'radians','degrees');
                   elseif RE<0 & IM>0 %2Q
                   ANGLE=abs(angledim(angle(V),'radians','degrees'));
                   elseif RE<0 & IM<0 %3Q
                   ANGLE=360+angledim(angle(V),'radians','degrees');
                   elseif RE>0 & IM<0 %4Q
                   ANGLE=360-abs(angledim(angle(V),'radians','degrees'));
                   end
                   %Here we have to obtain the range measurements according
                   %to the SS measurements (RSS_noise).
                   %RSS=Pt-Ki*Pathloss(d). We obtain Ki from RSS_noise
                   %(from the target node to the anchors)
                   %In column 3 of RSS_noise we find the SS, in 
                   %column 2 of K we find the percentage of variation K
                   %We have to find the anchor and the target node
                   ANGLE=round(ANGLE);
                   if ANGLE==360
                        ANGLE=0;
                   end
                   MatchSS=find(RSS_noise(:,1)==Audibleanchors(Nodesforanchor(j),2) & RSS_noise(:,2)==h);
                   MatchANG=find(K(:,3)==ANGLE & K(:,1)==Audibleanchors(Nodesforanchor(j),2));
                   ranges_noise(j)=do*(10.^((P0-RSS_noise(MatchSS,3))/(10.*np.*K(MatchANG,2))));
               end
               while((abs(E_Soprime-E_So)>epsilon) & (Num_iteraciones <=50)) 
                   Num_iteraciones=Num_iteraciones+1;
                   Aiter=[];
                   b=[];
                   E_Soprime=0;
                   E_So=0;
                   for j=1:m %Now we are in the phase of the anchors of a specific EStimatedcoordinated
                        Aiter_concat=[(So(1,1)-X(Audibleanchors(Nodesforanchor(j),2),1))/sqrt((So(1,1)-X(Audibleanchors(Nodesforanchor(j),2),1))^2+(So(1,2)-X(Audibleanchors(Nodesforanchor(j),2),2))^2) (So(1,2)-X(Audibleanchors(Nodesforanchor(j),2),2))/sqrt((So(1,1)-X(Audibleanchors(Nodesforanchor(j),2),1))^2+(So(1,2)-X(Audibleanchors(Nodesforanchor(j),2),2))^2)];
                        Busq_NAN=[];
                        Busq_NAN=find(isnan(Aiter_concat)==1); %We have the problem of [NaN NaN] because So and Estimatedcoordinates have the same value, this occurs when two nodes shares the same position, thus they listen to each other
                        [u v]=size(Busq_NAN);
                        if v==2
                           % Estimatedcoordinates(Coordinatesanchor(j),2:3)
                           % So
                            flag=1;
                            break;                        
                        else
                            Aiter=[Aiter; Aiter_concat]; %the size of Aiter will depend of the number of anchors for the particular estimated node    
                            b_concat=[[(So(1,1)-X(Audibleanchors(Nodesforanchor(j),2),1))/sqrt((So(1,1)-X(Audibleanchors(Nodesforanchor(j),2),1))^2+(So(1,2)-X(Audibleanchors(Nodesforanchor(j),2),2))^2) ((So(1,2)-X(Audibleanchors(Nodesforanchor(j),2),2))/sqrt((So(1,1)-X(Audibleanchors(Nodesforanchor(j),2),1))^2+(So(1,2)-X(Audibleanchors(Nodesforanchor(j),2),2))^2))]*So' - ((sqrt((So(1,1)-X(Audibleanchors(Nodesforanchor(j),2),1))^2+(So(1,2)-X(Audibleanchors(Nodesforanchor(j),2),2))^2))-...
                                ranges_noise(j))];
                            b=[b; b_concat];
                            E_So_concat=(power((sqrt((So(1,1)-X(Audibleanchors(Nodesforanchor(j),2),1))^2+(So(1,2)-X(Audibleanchors(Nodesforanchor(j),2),2))^2))...
                                -ranges_noise(j),2));
                            E_So=E_So+E_So_concat;
                        end
                   end
                   %inv or pinv?
                   %COND=cond((Aiter')*Weights*Aiter)
                   if flag==0
                       checkinv(counter)=cond((Aiter')*Aiter);
                       Soprime=inv((Aiter')*Aiter)*(Aiter')*b; %New So computed
                       counter=counter+1;
                       Busq_NAN=[];
                       Busq_NAN=find(isnan(Soprime)==1);
                       [u v]=size(Busq_NAN);
                       if u==2
                            Soprime=Saux';
                       end
                       Soprime=Soprime';
                       for j=1:m
                           E_Soprime_concat=(power((sqrt((Soprime(1,1)-X(Audibleanchors(Nodesforanchor(j),2),1))^2+(Soprime(1,2)-X(Audibleanchors(Nodesforanchor(j),2),2))^2))-...
                               ranges_noise(j),2)); 
                           E_Soprime=E_Soprime+E_Soprime_concat;
                       end
                       So=Soprime; %Update values
                   else
                       break;
                   end
                   if(Num_iteraciones==50)
                        So=Saux;
                        fprintf(1,'--Max number of iterations allowed \n');
                        break;
                   end
               end
               fprintf(1,'--Num_iteraciones %d\n',Num_iteraciones);
               Num_iteraciones=0;
               flag=0;
               %In case that inv computed infinite values
               Busq_INF=[];
               Busq_INF=find(isinf(So)==1);
               [u v]=size(Busq_INF);
               if v==2
                   So=Saux; 
               end
               Estimatedcoordinates_mult(cont,:)=[h So];
              % flag=1;
               cont=cont+1;
           end
    end
end

   