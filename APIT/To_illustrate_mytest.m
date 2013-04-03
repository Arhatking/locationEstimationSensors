%This code helps to know if a particular point of a grid is inside of a
%triangle (a random triangle) by running the following tests:
%a) making RSS comparisons between anchors and comparing them with the RSS
% measurements of the target point
%b) comparing the average of the attenuations between the anchors and the 
%average of the attenuations between {anchor-target point}
%c) using trilateration and try to make it robust against noise. (See paper
%of Carnegie Mellon)
%d) try to make an iterative trilateration using a starting point ( which
%is going to be our final estimate of APIT_random_nonoise using
%Newton-raphson/least squares approach) Paper of Localization in Sensor
%Networks.
%--x1,x2,x3,r1,r2,r3

%A=[(x1-x3) (y1-y3)]
%  [(x2-x3) (y2-y3)]
%B=[r1^2-r3^2-x1^2+x3^2-y1^2+y3^2]
%  [r2^2-r3^2-x2^2+x3^2-y2^2+y3^2]
%x=((A^TA)^-1)A^TB

auxiliar1=1;
auxiliar2=1;
auxiliar3=1;
auxiliar4=1;
auxiliar5=1;
auxiliar6=1;
C1=[];
C2=[];
C3=[];
C4=[];
C5=[];
C6=[];

%If An inside of a triangle n then
%{A1}int{A2}int{A3} gives a region which the three circles shares, and
%inside of this region there is an area for which a node is outside of a
%triangle. Thus
%Boutsidetriangle+Binsidetriangle=B={A1}int{A2}int{A3}

%(x-h)^2+(y-k)^2=r^2
%(x-h)^2=r^2-(y-k)^2
%x-h=sqrt(r^2-(y-k)^2)
%x=sqrt(r^2-(y-k)^2)+h
%if y=0 (in order to evaluate the roots)
%x=sqrt(r^2-k^2)+h
a=[];
b1=[];
b2=[];
b3=[];
X1=[];
Y1=[];
Z1=[];
A=[];
y1=[];
y2=[];
y3=[];
yneg1=[];
yneg2=[];
yneg3=[];
RSS=[];
H=[];
Res=0.5;

%Vertexes of the triangle
A(1,:)=[5*rand(1,1) 10*rand(1,1)]; 
A(2,:)=[8*rand(1,1) 2*rand(1,1)]; 
A(3,:)=[5*rand(1,1) 1*rand(1,1)];  

%A(1,:)=[1.4220    4.6922];
%A(2,:)=[0.5182    1.9767];
%A(3,:)=[2.9140    0.4235];
%A1=[A 0]
A1(1,1:2)=A(1,:);
A1(2,1:2)=A(2,:);
A1(3,1:2)=A(3,:);
A1(:,3)=zeros(3,1);

%For Amatrix

%A=[(x3-x1) (y3-y1)]
%  [(x3-x2) (y3-y2)]

Amatrix=[A(3,1)-A(1,1) A(3,2)-A(1,2); A(3,1)-A(2,1) A(3,2)-A(2,2)];
%B=[r1^2-r3^2-x1^2+x3^2-y1^2+y3^2]
%  [r2^2-r3^2-x2^2+x3^2-y2^2+y3^2]

%x=((A^TA)^-1)A^TB

%Noise?
dev_standard=3.92; %[dB]
%Propagation exponent\
np=2.3;
%Reference distance
do=1; %[m]
%Reference power at do
P0=-37.466; %[dBm]


%Grid
cont=1;
cont2=1;
for r=0:Res:10 
    for s=0:Res:10
        %Matrix H contains the coordinates for each of the corners of the
        %squares of the grid
        H(cont,:)=[r s];
        cont=cont+1;
    end
end

H1=H;
[m n]=size(H);
H1(:,3)=zeros(m,1);

figure(1);
hold on;
cont=1;
x1=[];
Eso=1;
Esoprime=1000;

for i=1:m %4:4
    x=[];
    D_A1=sqrt(((H(i,1)-A(1,1)))^2+((H(i,2)-A(1,2)))^2);
    D_A2=sqrt(((H(i,1)-A(2,1)))^2+((H(i,2)-A(2,2)))^2);
    D_A3=sqrt(((H(i,1)-A(3,1)))^2+((H(i,2)-A(3,2)))^2);
    
    D_T1=sqrt(((A(1,1)-A(2,1)))^2+((A(1,2)-A(2,2)))^2);
    D_T2=sqrt(((A(2,1)-A(3,1)))^2+((A(2,2)-A(3,2)))^2);
    D_T3=sqrt(((A(3,1)-A(1,1)))^2+((A(3,2)-A(1,2)))^2);
    
    B=[(D_A1^2)-(D_A3^2)-(A(1,1)^2)+(A(3,1)^2)-(A(1,2)^2)+(A(3,2)^2);(D_A2^2)-(D_A3^2)-(A(2,1)^2)+(A(3,1)^2)-(A(2,2)^2)+(A(3,2)^2)];
    y=inv((Amatrix')*Amatrix)*(Amatrix')*B;
    x(i,:)=y';
    
    %Lets consider x(i,:) as an approximation to the real point H(i,:), now
    %we can apply Newton-raphson/least squares
    %so=x, b1=A(1,:). Thus
   % so=x(i,:);
   % while(abs(Esoprime-Eso)>0.01)
   %     Aiter=[(so(1,1)-A(1,1))/sqrt((so(1,1)-A(1,1))^2+(so(1,2)-A(1,2))^2) (so(1,2)-A(1,2))/sqrt((so(1,1)-A(1,1))^2+(so(1,2)-A(1,2))^2); (so(1,1)-A(2,1))/sqrt((so(1,1)-A(2,1))^2+(so(1,2)-A(2,2))^2) (so(1,2)-A(2,2))/sqrt((so(1,1)-A(2,1))^2+(so(1,2)-A(2,2))^2); (so(1,1)-A(3,1))/sqrt((so(1,1)-A(3,1))^2+(so(1,2)-A(3,2))^2) (so(1,2)-A(3,2))/sqrt((so(1,1)-A(3,1))^2+(so(1,2)-A(3,2))^2)];
   %     b=[[(so(1,1)-A(1,1))/sqrt((so(1,1)-A(1,1))^2+(so(1,2)-A(1,2))^2) ((so(1,2)-A(1,2))/sqrt((so(1,1)-A(1,1))^2+(so(1,2)-A(1,2))^2))]*y - ((sqrt((so(1,1)-A(1,1))^2+(so(1,2)-A(1,2))^2))-D_A1); [(so(1,1)-A(2,1))/sqrt((so(1,1)-A(2,1))^2+(so(1,2)-A(2,2))^2) (so(1,2)-A(2,2))/sqrt((so(1,1)-A(2,1))^2+(so(1,2)-A(2,2))^2)]*y - ((sqrt((so(1,1)-A(2,1))^2+(so(1,2)-A(2,2))^2))-D_A2); [(so(1,1)-A(3,1))/sqrt((so(1,1)-A(3,1))^2+(so(1,2)-A(3,2))^2) ((so(1,2)-A(3,2))/sqrt((so(1,1)-A(3,1))^2+(so(1,2)-A(3,2))^2))]*y - ((sqrt((so(1,1)-A(3,1))^2+(so(1,2)-A(3,2))^2))-D_A3)];
   %     soprime=pinv((Aiter')*Aiter)*(Aiter')*b;
   %     soprime=soprime';
   %     Esoprime=(power((sqrt((soprime(1,1)-A(1,1))^2+(soprime(1,2)-A(1,2))^2))-D_A1,2)+power((sqrt((soprime(1,1)-A(2,1))^2+(soprime(1,2)-A(2,2))^2))-D_A2,2)+power((sqrt((soprime(1,1)-A(3,1))^2+(soprime(1,2)-A(3,2))^2))-D_A3,2));
   %     Eso=(power((sqrt((so(1,1)-A(1,1))^2+(so(1,2)-A(1,2))^2))-D_A1,2)+power((sqrt((so(1,1)-A(2,1))^2+(so(1,2)-A(2,2))^2))-D_A2,2)+power((sqrt((so(1,1)-A(3,1))^2+(so(1,2)-A(3,2))^2))-D_A3,2));
   %     so=soprime;
   % end
    %Compute f' for the distance among pairs anchors and target node
    
   % plot(so(1,1),so(1,2),'rs','MarkerFaceColor','g') 
    
    RSS_A1_derivada=10*np*log10(exp(1))/D_A1; %1/D_A1
    RSS_A2_derivada=10*np*log10(exp(1))/D_A2;
    RSS_A3_derivada=10*np*log10(exp(1))/D_A3;
    
    AVG_RSS_A_derivada=(RSS_A1_derivada+RSS_A2_derivada+RSS_A3_derivada)/3;
    
    %Compute f' for the distances among the anchors, d/dx(logx) where x is
    %the distance
    RSS_T1_derivada=10*np*log10(exp(1))/D_T1;
    RSS_T2_derivada=10*np*log10(exp(1))/D_T2;
    RSS_T3_derivada=10*np*log10(exp(1))/D_T3;
    
    AVG_RSS_T_derivada=(RSS_T1_derivada+RSS_T2_derivada+RSS_T3_derivada)/3;
    
   % Test with the average of atenuations between anchors and average
   % between anchors and target node.
   % if AVG_RSS_T_derivada > AVG_RSS_A_derivada
   %    plot(H(i,1),H(i,2),'rs','MarkerFaceColor','r') %Means that the node is outside of the triangle, since the attenuations of the node w/respect to the anchors are smaller
   % else
   %    plot(H(i,1),H(i,2),'s','MarkerFaceColor','b') %Means that the node is inside 
   % end
    
    if D_A1 <= 1
        RSS_A1 = P0;
    else
        RSS_A1=P0-(10*np*log10(D_A1.*(1/do)));
    end
    if D_A2 <= 1
        RSS_A2 = P0;
    else
        RSS_A2=P0-(10*np*log10(D_A2.*(1/do)));
    end
    if D_A3 <= 1
        RSS_A3 = P0;
    else
        RSS_A3=P0-(10*np*log10(D_A3.*(1/do)));
    end
    if D_T1 <= 1
        RSS_T1 = P0;
    else
        RSS_T1=P0-(10*np*log10(D_T1.*(1/do)));
    end
    if D_T2 <= 1
        RSS_T2 = P0;
    else
        RSS_T2=P0-(10*np*log10(D_T2.*(1/do)));
    end
    if D_T3 <= 1
        RSS_T3 = P0;
    else
        RSS_T3=P0-(10*np*log10(D_T3.*(1/do)));
    end
    x1(i,:)=[x(i,:) 0];
    Mt=cross(x1(i,:)-A1(1,:),A1(2,:)-A1(1,:)); % H-A,B-A   ... change for H1 
    Nt=cross(x1(i,:)-A1(2,:),A1(3,:)-A1(2,:)); % H-B,C-B
    Ot=cross(x1(i,:)-A1(3,:),A1(1,:)-A1(3,:)); % H-C,A-C
   % RSS_Comparisons
    if (RSS_A1 > RSS_T1)  & (RSS_A2 > RSS_T1) & (RSS_A1 > RSS_T3) & (RSS_A3 > RSS_T3) & (RSS_A2 > RSS_T2) & (RSS_A3 > RSS_T2)
                    %Means that node possibly is inside of the triangle
                    doomy=1;
                    %                plot(H(i,1),H(i,2),'rs','MarkerFaceColor','b')
    else 
                    %Means that node possibly is outside of the triangle
                    plot(H(i,1),H(i,2),'bs','MarkerFaceColor','r')
    end
  
  
    if RSS_T1 > RSS_A1  %| RSS_T3 > RSS_A1 
                    plot(H(i,1),H(i,2),'rs','MarkerFaceColor','r')
                    C1(auxiliar1,:)=H(i,:);
                    auxiliar1=auxiliar1+1;
    end
    if RSS_T1 > RSS_A2  %| RSS_T2 > RSS_A2 
                    plot(H(i,1),H(i,2),'vg','MarkerFaceColor','g')
                    C2(auxiliar2,:)=H(i,:);
                    auxiliar2=auxiliar2+1;
    end
    if RSS_T2 > RSS_A2
                     plot(H(i,1),H(i,2),'dy','MarkerFaceColor','y')
                     C3(auxiliar3,:)=H(i,:);
                     auxiliar3=auxiliar3+1;
    end
    if RSS_T2 > RSS_A3
                     plot(H(i,1),H(i,2),'dk','MarkerFaceColor','k')
                     C4(auxiliar4,:)=H(i,:);
                     auxiliar4=auxiliar4+1;
    end
    if RSS_T3 > RSS_A3  %| RSS_T3 > RSS_A1 
                    plot(H(i,1),H(i,2),'bs','MarkerFaceColor','b')
                    C5(auxiliar5,:)=H(i,:);
                    auxiliar5=auxiliar5+1;
    end
    if RSS_T3 > RSS_A1
                    plot(H(i,1),H(i,2),'om','MarkerFaceColor','m')
                    C6(auxiliar6,:)=H(i,:);
                    auxiliar6=auxiliar6+1;
    end
     %else 
                    %Means that node possibly is inside of the triangle
     %               plot(H(i,1),H(i,2),'bs','MarkerFaceColor','b')
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %For surface purposes
   %Whether it is inside or outside of the triangle
   
    if ((Mt(1,3)>0)&(Nt(1,3)>0)&(Ot(1,3)>0)) | ((Mt(1,3)<0)&(Nt(1,3)<0)&(Ot(1,3)<0))
        RSS(i,:)=[H1(i,:) RSS_A1 RSS_A2 RSS_A3 1]; %Inside
        RSSi(cont,:)=[H1(i,:) RSS_A1 RSS_A2 RSS_A3];
        %X1(cont,:)=[i H(i,1)];
        %Y1(cont,:)=[i H(i,2)];
        %Z1(cont,:)=[i RSS_A1];
        cont=cont+1;
   %     plot(x(i,1),x(i,2),'rs','MarkerFaceColor','r') %...change for H
    else
        RSS(i,:)=[H1(i,:) RSS_A1 RSS_A2 RSS_A3 0]; %outside
        RSSo(cont2,:)=[H1(i,:) RSS_A1 RSS_A2 RSS_A3];
        cont2=cont2+1;
        %plot(x(i,1),x(i,2),'bs','MarkerFaceColor','b') %.. change for H
    end
end


line([A(1,1) A(2,1)],[A(1,2) A(2,2)],'Color','b','LineStyle','-');
%Compute distance1
d1=sqrt(((A(2,1)-A(1,1))^2)+((A(2,2)-A(1,2))^2));
line([A(2,1) A(3,1)],[A(2,2) A(3,2)],'Color','b','LineStyle','-');
%Compute distance2
d2=sqrt(((A(2,1)-A(3,1))^2)+((A(2,2)-A(3,2))^2));
line([A(3,1) A(1,1)],[A(3,2) A(1,2)],'Color','b','LineStyle','-');
%Compute distance3
d3=sqrt(((A(3,1)-A(1,1))^2)+((A(3,2)-A(1,2))^2));

hold off;

figure(2);
line([A(1,1) A(2,1)],[A(1,2) A(2,2)],'Color','b','LineStyle','-');
hold on;
line([A(2,1) A(3,1)],[A(2,2) A(3,2)],'Color','b','LineStyle','-');
line([A(3,1) A(1,1)],[A(3,2) A(1,2)],'Color','b','LineStyle','-');
plot(C1(:,1), C1(:,2), 'rs','MarkerFaceColor','r');
hold off;
figure(3);
line([A(1,1) A(2,1)],[A(1,2) A(2,2)],'Color','b','LineStyle','-');
hold on;
line([A(2,1) A(3,1)],[A(2,2) A(3,2)],'Color','b','LineStyle','-');
line([A(3,1) A(1,1)],[A(3,2) A(1,2)],'Color','b','LineStyle','-');
plot(C2(:,1),C2(:,2),'vg','MarkerFaceColor','g')
hold off;
figure(4);
line([A(1,1) A(2,1)],[A(1,2) A(2,2)],'Color','b','LineStyle','-');
hold on;
line([A(2,1) A(3,1)],[A(2,2) A(3,2)],'Color','b','LineStyle','-');
line([A(3,1) A(1,1)],[A(3,2) A(1,2)],'Color','b','LineStyle','-');
plot(C3(:,1),C3(:,2),'dy','MarkerFaceColor','y')
hold off;
figure(5);
line([A(1,1) A(2,1)],[A(1,2) A(2,2)],'Color','b','LineStyle','-');
hold on;
line([A(2,1) A(3,1)],[A(2,2) A(3,2)],'Color','b','LineStyle','-');
line([A(3,1) A(1,1)],[A(3,2) A(1,2)],'Color','b','LineStyle','-');
plot(C4(:,1),C4(:,2),'dk','MarkerFaceColor','k')
hold off;
figure(6);
line([A(1,1) A(2,1)],[A(1,2) A(2,2)],'Color','b','LineStyle','-');
hold on;
line([A(2,1) A(3,1)],[A(2,2) A(3,2)],'Color','b','LineStyle','-');
line([A(3,1) A(1,1)],[A(3,2) A(1,2)],'Color','b','LineStyle','-');
plot(C5(:,1),C5(:,2),'bs','MarkerFaceColor','b')
hold off;
figure(7);
line([A(1,1) A(2,1)],[A(1,2) A(2,2)],'Color','b','LineStyle','-');
hold on;
line([A(2,1) A(3,1)],[A(2,2) A(3,2)],'Color','b','LineStyle','-');
line([A(3,1) A(1,1)],[A(3,2) A(1,2)],'Color','b','LineStyle','-');
plot(C6(:,1),C6(:,2),'om','MarkerFaceColor','m')
hold off;

%X of Vertex {1,:}
%h=A(1,1)
%k=A(1,2)
cont=1;
cont2=1;
for a=(A(1,1)-d1):0.001:(A(1,1)+d1)
    b1(cont2)=a;
    cont2=cont2+1;
    y1(cont)=sqrt(d1^2-(a-A(1,1)).^2)+A(1,2);
    cont=cont+1;
end
cont=1;
for a=(A(1,1)-d1):0.001:(A(1,1)+d1)
    yneg1(cont)=-sqrt(d1^2-(a-A(1,1)).^2)+A(1,2);
    cont=cont+1;
end

%X of Vertex {2,:}
%h=A(1,1)
%k=A(1,2)
cont=1;
cont2=1;
for a=(A(2,1)-d2):0.001:(A(2,1)+d2)
    b2(cont2)=a;
    cont2=cont2+1;
    y2(cont)=sqrt(d2^2-(a-A(2,1)).^2)+A(2,2);
    cont=cont+1;
end
cont=1;
for a=(A(2,1)-d2):0.001:(A(2,1)+d2)
    yneg2(cont)=-sqrt(d2^2-(a-A(2,1)).^2)+A(2,2);
    cont=cont+1;
end

%X of Vertex {3,:}
%h=A(1,1)
%k=A(1,2)
cont=1;
cont2=1;
for a=(A(3,1)-d3):0.001:(A(3,1)+d3)
    b3(cont2)=a;
    cont2=cont2+1;
    y3(cont)=sqrt(d3^2-(a-A(3,1)).^2)+A(3,2);
    cont=cont+1;
end
cont=1;
for a=(A(3,1)-d3):0.001:(A(3,1)+d3)
    yneg3(cont)=-sqrt(d3^2-(a-A(3,1)).^2)+A(3,2);
    cont=cont+1;
end
hold on;
%plot(b1,y1);
%plot(b1,yneg1);
%plot(b2,y2);
%plot(b2,yneg2);
%plot(b3,y3);
%plot(b3,yneg3);

 set(gca,'xlim',[-0.5 10.5]) 
 set(gca,'ylim',[-0.5 10.5])
 set(gca,'xTick',0:Res:10)
 set(gca,'yTick',0:Res:10)
 grid;
 
 hold off;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %To determine RSS around the contourn of the triangle
 %Compute m's for the lines.
 m1=(A(2,2)-A(1,2))/(A(2,1)-A(1,1));
 m2=(A(3,2)-A(2,2))/(A(3,1)-A(2,1));
 m3=(A(3,2)-A(1,2))/(A(3,1)-A(1,1));
 %One side->m1
 temp=1;
 for a=A(1,1):0.1:A(2,1) %barrido en x
     y_s1=m1*a+(A(1,2)-(m1*A(1,1))); %a,y_s1 are the coordinates that lie on the line of the triangle
     d_s1=sqrt(((a-A(1,1)))^2+((y_s1-A(1,2)))^2); %we compute the distance from this point to vertix 1
     d_s2=sqrt(((a-A(2,1)))^2+((y_s1-A(2,2)))^2); %we compute the distance from this point to vertix 2
     d_s3=sqrt(((a-A(3,1)))^2+((y_s1-A(3,2)))^2); %we compute the distance from this point to vertix 3
     if d_s1 <= 1
        RSS_c1= P0;
    else
        RSS_c1=P0-(10*np*log10(d_s1.*(1/do)));
     end
    if d_s2 <= 1
        RSS_c2= P0;
    else
        RSS_c2=P0-(10*np*log10(d_s2.*(1/do)));
    end
    if d_s3 <= 1
        RSS_c3= P0;
    else
        RSS_c3=P0-(10*np*log10(d_s3.*(1/do)));
    end
    RSS_c(temp,:)=[RSS_c1 RSS_c2 RSS_c3];
    temp=temp+1;
 end
 %Second side->m2
 for a=A(2,1):0.1:A(3,1)
     y_s2=m2*a+(A(2,2)-(m2*A(2,1)));
     d_s1=sqrt(((a-A(1,1)))^2+((y_s1-A(1,2)))^2); %we compute the distance from this point to vertix 1
     d_s2=sqrt(((a-A(2,1)))^2+((y_s1-A(2,2)))^2); %we compute the distance from this point to vertix 2
     d_s3=sqrt(((a-A(3,1)))^2+((y_s1-A(3,2)))^2); %we compute the distance from this point to vertix 3
     if d_s1 <= 1
        RSS_c1= P0;
    else
        RSS_c1=P0-(10*np*log10(d_s1.*(1/do)));
     end
    if d_s2 <= 1
        RSS_c2= P0;
    else
        RSS_c2=P0-(10*np*log10(d_s2.*(1/do)));
    end
    if d_s3 <= 1
        RSS_c3= P0;
    else
        RSS_c3=P0-(10*np*log10(d_s3.*(1/do)));
    end
    RSS_c(temp,:)=[RSS_c1 RSS_c2 RSS_c3];
    temp=temp+1;
 end
 %Third side->m3
 for a=A(3,1):0.1:A(1,1)
     y_s3=m3*a+(A(3,2)-(m3*A(3,1)));
     d_s1=sqrt(((a-A(1,1)))^2+((y_s1-A(1,2)))^2); %we compute the distance from this point to vertix 1
     d_s2=sqrt(((a-A(2,1)))^2+((y_s1-A(2,2)))^2); %we compute the distance from this point to vertix 2
     d_s3=sqrt(((a-A(3,1)))^2+((y_s1-A(3,2)))^2); %we compute the distance from this point to vertix 3
     if d_s1 <= 1
        RSS_c1= P0;
    else
        RSS_c1=P0-(10*np*log10(d_s1.*(1/do)));
     end
    if d_s2 <= 1
        RSS_c2= P0;
    else
        RSS_c2=P0-(10*np*log10(d_s2.*(1/do)));
    end
    if d_s3 <= 1
        RSS_c3= P0;
    else
        RSS_c3=P0-(10*np*log10(d_s3.*(1/do)));
    end
    RSS_c(temp,:)=[RSS_c1 RSS_c2 RSS_c3];
    temp=temp+1;
 end
 %At this poing we
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%z->either RSS_A1, RSS_A2, RSS_A3, {x,y}->H
% figure(2);
% scatter3(RSS(:,1), RSS(:,2), RSS(:,4),'filled');
% hold on;
% scatter3(RSS(:,1), RSS(:,2), RSS(:,5),'r','filled');
% scatter3(RSS(:,1), RSS(:,2), RSS(:,6),'g','filled');
% hold off;
% figure(3);
% scatter3(RSSi(:,1), RSSi(:,2), RSSi(:,4),'filled');
% hold on;
% scatter3(RSSi(:,1), RSSi(:,2), RSSi(:,5),'r','filled');
% scatter3(RSSi(:,1), RSSi(:,2), RSSi(:,6),'g','filled');
% hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %z->RSS_A3, {x,y}->RSS_A1,RSS_A2 (both inside and outside)
 %figure(4);
 %[A,B]=meshgrid(RSS(:,4), RSS(:,5));
 %Zrss=griddata(RSS(:, 4), RSS(:,5), RSS(:,6), A, B);
 %mesh(A,B,Zrss); %SURFL
 %shading interp
 %colormap(hsv);
 %scatter3(RSS(:,4), RSS(:,5), RSS(:,6),'filled');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %z->RSS_A3, {x,y}->RSS_A1,RSS_A2 (inside)
 %figure(5);
 %[C,D]=meshgrid(RSSi(:,4), RSSi(:,5));
 %Zrss=griddata(RSSi(:, 4), RSSi(:,5), RSSi(:,6), A, B);
 %mesh(A,B,Zrss);
 %shading interp
 %colormap(hsv);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %z->RSS_A3, {x,y}->RSS_A1,RSS_A2 (outside)
 %figure(6);
 %[C,D]=meshgrid(RSSo(:,4), RSSo(:,5));
 %Zrss=griddata(RSSo(:, 4), RSSo(:,5), RSSo(:,6), A, B);
 %mesh(A,B,Zrss);
 %shading interp
% colormap(hsv);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %z->RSS_A3, {x,y}->RSS_A1,RSS_A2 (outside)
% figure(7);
% [C,D]=meshgrid(RSS_c(:,1), RSS_c(:,2));
% Zrss=griddata(RSS_c(:, 1), RSS_c(:,2), RSS_c(:,3), A, B);
% mesh(A,B,Zrss);
% shading interp
% colormap(hsv);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % figure(6);
 % [X, Y]=meshgrid(RSS(:,1),RSS(:,2)) 
 % Z1=griddata(RSS(:,1),RSS(:,2),RSS(:,4),X,Y); %vectors {x,y,z}, and elements of the meshgrid
 % mesh(X,Y,Z1); %surfl
 % shading interp
 % colormap(hsv);
% hold on;
% Z2=griddata(RSS(:,1),RSS(:,2),RSS(:,5),X,Y);
% mesh(X,Y,Z2);
% shading interp
% colormap(hsv);
% Z3=griddata(RSS(:,1),RSS(:,2),RSS(:,6),X,Y);
% mesh(X,Y,Z3);
% shading interp
% colormap(gray);
% hold off;
