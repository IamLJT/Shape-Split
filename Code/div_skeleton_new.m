
function [bw,I0,x,y,x1,y1,aa,bb]=div_skeleton_new(ro,T,T1,I0,no_vertice)%,cor)
%----------------------cor is for corpos

%I0=imread('original/camel-15.gif');
%%%I0=imread('can.bmp');
%%%%I0=cor;
%I0=imread('4.jpg');
if max(max(I0))>1;
I0=im2bw(I0);
end
%I0=1-I0;%add
%[aa,bb,I5]=GetContour(I0);
 [aa,bb,I5]=GetContour2(I0);    %   ��ȡͼ��������Ϣ��aa��bbΪ���������꣬
                                %   I5Ϊ�����ıߣ��õ㴦����������Ϊ1����������Ϊ0
% B = bwboundaries(I0);
%[aa,bb]=TraceContour(I1)

%I2=im2bw(I1,0.5);
I3=bwperim(I0);                 %   ��ȡͼ���Ե��Ϣ
%I4=pre_deal(I3);
%[aa,bb,I5]=GetContour(I4);
%%%%%%%%[a,b,NO]=EvolutionNew2(aa,bb,25);
[s,value]=evolution([aa',bb'],no_vertice);
a=s(:,1);
b=s(:,2);
NO=length(a);
%%d=0;
%%while d<T,
   
  %% [ta,tb,n]=EvolutionPoint(a,b,NO);
 %%a=ta;
   %%b=tb;
   %%NO=n;
   %%d=averdist(aa,bb,a,b,NO);
  %%if NO<5,
   %%break;
   %%end
   %%end
%--------------------------------3_16
%[aaa,bbb,NONO]=DelConvex(a,b,NO);   

%mark=Curvediv(aa,bb,a,b,NO,I3);
 
    [convex_temp,concave_temp]=FindConvex(a,b,NO);%--------------3_16
    %   ��͹��Ͱ���ֿ�
     convex=zeros(1,NO);
     convex(convex_temp)=1;
%--------------------------------3_16  add    
   m=length(a);
    for i=1:m;
        intersect(i)=Intersecto(a,b,i,concave_temp,T1);
    end
    final=convex-intersect;
    remain=find(final==1);
    NONO=length(remain);
    aaa=a(remain); bbb=b(remain);
%---------------------------------------above 3_16
mark=Curvediv1(aa,bb,aaa,bbb,NONO,I3);
[p,q]=find(mark~=0);
u=length(p);
for i=1:u;
    mark(p(i),q(i))=mark(p(i),q(i))+1;
end
mark=MarkOther(mark, I3, I5);
bw=SkeletonGrow1(I0,ro,mark);
x=a;
x(NO+1)=a(1);
y=b;
y(NO+1)=b(1);
x1=aaa;
y1=bbb;

%figure;plot(x,y);
%figure;plot(aa,bb);
