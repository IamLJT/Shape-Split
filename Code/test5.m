
close all
clear all
clc
% bw = imread('data_-4824099_bw.bmp');
% bw = imread('1.bmp');
% bw=imread('camel-20.jpg');
% bw=imread('horse-6.jpg');
% bw=imread('data_93368693_bw.bmp');
bw=imread('data_-103712361_bw.bmp');
bw = im2bw(bw);
[m0,n0]=size(bw);
I_tmp=logical(zeros(m0+4,n0+4));
I_tmp(3:m0+2,3:n0+2)=bw(:,:);
bw=I_tmp;
bw = medfilt2(bw,[3,3]);
figure(1);
imshow(bw);
[m,n]=size(bw);
I0=1-bw;                                 %黑白颠倒
[aa,bb,I]=GetContour2(I0);             % 通过GetContour1可以得到边界轮廓线，以及边界上的坐标
I3=bwperim(I0);
[s,value]=evolution([aa',bb'],14);
a0=s(:,1);
b0=s(:,2);
NO=length(a0);
[convex_temp,concave_temp]=FindConvex(a0,b0,NO);      %convex为凸
 convex=zeros(1,NO);
 convex(convex_temp)=1;
    m=length(a0);
    for i=1:m;
        intersect(i)=Intersecto(a0,b0,i,concave_temp,1);
    end
    final=convex-intersect;
    remain=find(final==1);
    NONO=length(remain);           %   remain剩余凸点的个数
    aaa=a0(remain); bbb=b0(remain);
  mark=Curvediv1(aa,bb,aaa,bbb,NONO,I3);          %在边界曲线上做DCE后的顶点标号
[p,q]=find(mark~=0);
u=length(p);
for i=1:u;
    mark(p(i),q(i))=mark(p(i),q(i))+1;
end
mark=MarkOther(mark,I3, I);

bw=SkeletonGrow1(I0,4,mark);
bw = bwmorph(bw, 'thin', inf);
figure(2);
imshow(bw+I3);
hold on;
% [aa,bb,I]=GetContour1(I0);
N_limitpoint=0; % 分叉点延长系数
[a, b, bw]=FindJunctionPoint(bw,N_limitpoint);
figure(2);
imshow(bw+I3);
hold on;
for i=1:length(a)
    Junc_Pointx=a(i);
    Junc_Pointy=b(i);
    plot(Junc_Pointy,Junc_Pointx,'*','Color',...
        [0.25*mod(i,4),1-0.1*mod(i,10),0.2*(mod(i,5))]);
    hold on;
end

range=RangeDivide(bw, aa, bb, I);
for i=1:length(range)
    start_=range(i);
    if i==length(range)
        end_=range(1);
    else
        end_=range(i+1);
    end
    if end_<start_
        end_=end_+length(aa);
    end
    for j=start_:end_
        k=j;
        if k>length(aa)
            k=k-length(aa);
        end
        plot(bb(k),aa(k));
        hold on;
    end
end
[dist,lab]=bwdist(I);         %   得到距离变换矩阵

%-----------------骨架划分-------------------------------
[x_,y_,sx,sy,Junc_p]=GetSkelRange(bw,N_limitpoint);
%-----------------进一步的分叉点获取---------------------
% [x_,y_,sx,sy,Junc_p,a,b]=GetFurJuncPoint(x_,y_,sx,sy,Junc_p,a,b);
%-------------------------------------------------------
threshold=2.5;      % 视觉显著度阈值
Contour_length=[];  % 轮廓长度数组
SplitLines=[];      % 存储分割线
Split_plot=[];      % 分割线句柄
index_split=0;      % 分割线序号
index=0;
N_Slope=50;

for i=1:length(a)
    Junc_Pointx=a(i);
    Junc_Pointy=b(i);
    %------------------寻找分割点--------------------------
    [x, y, p]=CreateSplitPoint(range, aa, bb, Junc_Pointx, Junc_Pointy);
    %------------------------------------------------------
%     plot(Junc_Pointy,Junc_Pointx,'*','Color',[0.25*mod(i,4),1-0.1*mod(i,10),0.2*(mod(i,5))]);
%     hold on;
    plot(y,x,'*','Color',[0.25*mod(i,4),1-0.1*mod(i,10),0.2*(mod(i,5))]);
    hold on;

    %-----------------获取分叉点处斜率----------------------
%     [slope_x,slope_y]=GetJuncSlope(bw,Junc_Pointx, Junc_Pointy);
    % 对于弯曲度比较大的应该怎么求斜率？
    [slope_y, slope_x]=GetJuncSlope2(bw, x_, y_, sx, sy, Junc_Pointy, Junc_Pointx, dist, N_Slope);
    %------------------------------------------------------
    for j=1:length(slope_x)
        index_l=0;
        index_r=0;
        left=[];
        right=[];
        x1=slope_x(j);
        y1=slope_y(j);
        theta1=atan2(y1,x1);
        if theta1<0
            theta1=theta1+2*pi;
        end
        for k=1:length(x)
            x2=x(k)-Junc_Pointx;
            y2=y(k)-Junc_Pointy;
            theta2=atan2(y2,x2);
            if theta2<0
                theta2=theta2+2*pi;
            end
        %按照斜率将投影点分为左轮廓和右轮廓点
            if (theta2-theta1>=0&&theta2-theta1<=pi)...
                    ||(theta2-theta1<=-pi)
                index_l=index_l+1;
                left(index_l)=p(k);
            else
                index_r=index_r+1;
                right(index_r)=p(k);
            end
        end
        figure(3);
        imshow(bw+I);
        hold on;
        plot(Junc_Pointy,Junc_Pointx,'*r');
        quiver(Junc_Pointy,Junc_Pointx,y1,x1,'y','lineWidth',2);
        plot(bb(left),aa(left),'*b');
        plot(bb(right),aa(right),'*g');
        %-----------以就近点作为分割点-------------------------
        mid=inf;
        min_d_l=inf;
        min_d_r=inf;
        mid_theta=inf;
        l_p=0;
        r_p=0;  % 判断是否有符合条件的投影点
        x3=slope_x(j);
        y3=slope_y(j);
        theta3=atan2(y3,x3);
        
        candi_pointx=[];
        candi_pointy=[];
        
        
        for e=1:length(left)
            for f=1:length(right)
%                 figure(3);
%                 h=plot([bb(left(e)),bb(right(f))],[aa(left(e)),aa(right(f))],'-r');
%                 delete(h);
                x1=aa(left(e))-Junc_Pointx;
                y1=bb(left(e))-Junc_Pointy;
                theta1=atan2(y1,x1);
                theta1=theta1-theta3;
                x2=aa(right(f))-Junc_Pointx;
                y2=bb(right(f))-Junc_Pointy;
                theta2=atan2(y2,x2);
                theta2=theta2-theta3;
                x4=(x1+x2+2*Junc_Pointx)/2-Junc_Pointx;
                y4=(y1+y2+2*Junc_Pointy)/2-Junc_Pointy;
                theta4=atan2(y4,x4);
                mid_l=(aa(left(e))-Junc_Pointx)^2+((bb(left(e))-Junc_Pointy))^2;
                mid_r=(aa(right(f))-Junc_Pointx)^2+((bb(right(f))-Junc_Pointy))^2;
                min_d=(aa(left(e))-aa(right(f)))^2+(bb(left(e))-bb(right(f)))^2;
%                 min_d=x4^2+y4^2;

                if theta1<-pi
                    theta1=theta1+2*pi;
                end
                if theta1>pi
                    theta1=theta1-2*pi;
                end
                if theta2<-pi
                    theta2=theta2+2*pi;
                end
                if theta2>pi
                    theta2=theta2-2*pi;
                end
                
                % 设置条件：1、距离短；2、离分叉点在一定范围内；
                %          3、优先要同锐角,如果没有的话加上中心点在斜率方向上
                
                if mid>min_d&& ...
                        mid_l<(1.5*dist(Junc_Pointx,Junc_Pointy))^2&&mid_r<(1.5*dist(Junc_Pointx,Junc_Pointy))^2&&...
                        ((abs(theta1)<=pi/2&&abs(theta1)>=0&&abs(theta2)<=pi/2&&abs(theta2)>=0)...
                        ||((theta4-theta3<=pi/2&&theta4-theta3>=-pi/2)|| ...
                        (theta4-theta3<=2*pi&&theta4-theta3>=3*pi/2)|| ...
                        (theta4-theta3>=-2*pi&&theta4-theta3<=-3*pi/2)))
%                     mid=mid_l+mid_r;
                    mid=min_d;
                    l_p=left(e);
                    r_p=right(f);
                end
            end
        end
        if l_p==0||r_p==0
            for e=1:length(left)
                for f=1:length(right)
%                         figure(3);
%                         h=plot([bb(left(e)),bb(right(f))],[aa(left(e)),aa(right(f))],'-r');
%                         delete(h);
                    x1=aa(left(e))-Junc_Pointx;
                    y1=bb(left(e))-Junc_Pointy;
                    theta1=atan2(y1,x1);
                    theta1=theta1-theta3;
                    x2=aa(right(f))-Junc_Pointx;
                    y2=bb(right(f))-Junc_Pointy;
                    theta2=atan2(y2,x2);
                    theta2=theta2-theta3;
                    x4=(x1+x2+2*Junc_Pointx)/2-Junc_Pointx;
                    y4=(y1+y2+2*Junc_Pointy)/2-Junc_Pointy;
                    theta4=atan2(y4,x4);
                    theta4=theta4-theta3;

                    mid_l=(aa(left(e))-Junc_Pointx)^2+((bb(left(e))-Junc_Pointy))^2;
                    mid_r=(aa(right(f))-Junc_Pointx)^2+((bb(right(f))-Junc_Pointy))^2;
                    min_d=(aa(left(e))-aa(right(f)))^2+(bb(left(e))-bb(right(f)))^2;
    %                 min_d=x4^2+y4^2;

                    if theta1<-pi
                        theta1=theta1+2*pi;
                    end
                    if theta1>pi
                        theta1=theta1-2*pi;
                    end
                    if theta2<-pi
                        theta2=theta2+2*pi;
                    end
                    if theta2>pi
                        theta2=theta2-2*pi;
                    end
                    if theta4<-pi
                        theta4=theta4+2*pi;
                    end
                    if theta4>pi
                        theta4=theta4-2*pi;
                    end

                    if mid>min_d&& ...
                        mid_l<(1.5*dist(Junc_Pointx,Junc_Pointy))^2&&mid_r<(1.5*dist(Junc_Pointx,Junc_Pointy))^2&&...
                        ((abs(theta1)>=pi/2&&abs(theta1)<=pi&&abs(theta2)>=pi/2&&abs(theta2)<=pi)||...
                        (abs(theta4)>=pi/2&&abs(theta4)<=pi))
%                           mid=mid_l+mid_r;
                        mid=min_d;
                        l_p=left(e);
                        r_p=right(f);
                    end
                end
            end
        end

         figure(2);
         if l_p~=0&&r_p~=0
             h=plot([bb(l_p),bb(r_p)],[aa(l_p),aa(r_p)],'-r');
             index_split=index_split+1;
             SplitLines(index_split,1)=l_p;
             SplitLines(index_split,2)=r_p;
             SplitLines(index_split,3)=Junc_p(i);
             Split_plot(index_split)=h;
             hold on;
         end
    end
%     for k=1:length(x)
%         temp(x(k),y(k))=1;
%     end
end

[m,n]=size(SplitLines);

%-----测试---------------
% tmp_I=bw+I3;
% figure(4);
% imshow(tmp_I);
% hold on;
%-----------------------

for i=1:max(Junc_p)+1
    for j=1:m
        % 如果该分割线已排除或优先级大于当前选择的优先级则不进行计算
        if SplitLines(j,3)<=0||SplitLines(j,3)>i
            continue;
        end
%         figure(4);
%         plot([bb(SplitLines(j,1)),bb(SplitLines(j,2))],[aa(SplitLines(j,1)),aa(SplitLines(j,2))],'-r')
        [PVS,Contour_length, distance]=GetPVS(aa,bb,SplitLines(j,1),SplitLines(j,2),Contour_length,SplitLines(j,3));
        if PVS<threshold
            SplitLines(j,3)=-1;
            [m0,n0]=size(Contour_length);
            for k=1:m0
                if (Contour_length(k,1)==SplitLines(j,1)&&(Contour_length(k,2)==SplitLines(j,2)))||...
                        (Contour_length(k,1)==SplitLines(j,2)&&(Contour_length(k,2)==SplitLines(j,1)))
                    Contour_length(k,3)=distance;
                end
            end
            figure(2);
            delete(Split_plot(j));
        end
    end
end




 