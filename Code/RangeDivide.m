function range=RangeDivide(skel_dist, aa, bb, contour)
%-----------------------------------------------------------
%Name:  range=RangeDivide(skel_dist, aa, bb, contour)
%Dest:  区域划分
%Para:  skel_dist 骨架图像
%       aa,bb 轮廓点坐标链表
%       contour 轮廓点图像
%Return:range 划分区域
%-----------------------------------------------------------
[end_ps_x,end_ps_y]=FindEndPoints(skel_dist);
[dist,lab]=bwdist(contour);         %   得到距离变换矩阵
[m,n]=size(contour);
for k=1:length(end_ps_x)
    [yy(k),xx(k)]=Lab2Pos(lab(end_ps_x(k),end_ps_y(k)),m,n);
end
k=0;
for i=1:length(xx)
    for j=1:length(aa)
        if aa(j)==xx(i)&&bb(j)==yy(i)
            k=k+1;
            range(k)=j;
            break;
        end
    end
end
range=sort(range);
return;

function [end_ps_x,end_ps_y]=FindEndPoints(skel_dist)
%-----------------------------------------------------------
%Name:  [end_ps_x,end_ps_y]=FindEndPoints(skel_dist)
%Dest:  寻找骨架上尾端的点
%Para:  skel_dist 骨架图像
%Return:end_ps_x,end_ps_y 尾端点坐标
%-----------------------------------------------------------
[m,n]=size(skel_dist);
out=BOHitOrMiss(skel_dist, 'end');
[end_ps_y, end_ps_x]=Lab2Pos(find(1==out), m, n);
return