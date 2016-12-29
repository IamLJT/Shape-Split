function [slope_x, slope_y]=GetJuncSlope2(skel_dist, start_s, end_s, sx, sy, Junc_Pointx, Junc_Pointy, dist, N)
%-------------------------------------
%Name:  [slope_x, slope_y]=GetJuncSlope2...
%           (start_s, end_s, sx, sy, Junc_Pointx, Junc_Pointy)
%Dest:  分叉点斜率获取
%Para:  start_s,end_s 骨架分支起始点、终止点序号
%       sx,sy 轮廓区域
%       Junc_Pointx,Junc_Pointy 分叉点
%       dist 轮廓距离变换矩阵
%       N 骨架分支采样点数
%Return:slope_x,slope_y 斜率获取
%-------------------------------------
index=0;
slope_x=[];
slope_y=[];
[end_ps_x,end_ps_y]=FindEndPoints(skel_dist);
for i=1:length(start_s)
    if start_s(i)~=end_s(i)
        %   判断是否端点包含所求分叉点
        st_e=0;     % 是否包含端点
        st_f=0;
        ed_f=0;
        len=0;
        if sx(start_s(i))==Junc_Pointx&&sy(start_s(i))==Junc_Pointy
            st_f=1;
            for j=1:length(end_ps_x)
                if end_ps_y(j)==sx(end_s(i))&&end_ps_x(j)==sy(end_s(i))
                    st_e=1;
                    break;
                end
            end
        elseif sx(end_s(i))==Junc_Pointx&&sy(end_s(i))==Junc_Pointy
            ed_f=1;
            for j=1:length(end_ps_x)
                if end_ps_y(j)==sx(start_s(i))&&end_ps_x(j)==sy(start_s(i))
                    st_e=1;
                    break;
                end
            end
        end
        if st_f==1||ed_f==1
            if st_e~=1
                % 加入距离小于最大内切圆半径的分叉点去除的判决条件
                d=sqrt((sx(start_s(i))-sx(end_s(i)))^2+(sy(start_s(i))-sy(end_s(i)))^2);
                if d<dist(Junc_Pointy,Junc_Pointx)
                    continue;
                end
            end
                
            sum_x=0;
            sum_y=0;
            if st_f==1
                for j=start_s(i):end_s(i)
                    sum_x=sum_x+sx(j);
                    sum_y=sum_y+sy(j);
                    if (j-start_s(i)+1>=N)
                        break;
                    end
                end
                len=j-start_s(i)+1;
            else
                for j=end_s(i):-1:start_s(i)
                    sum_x=sum_x+sx(j);
                    sum_y=sum_y+sy(j);
                    if (end_s(i)-j+1>=N)
                        break;
                    end
                end
                len=end_s(i)-j+1;
            end
            
            sum_x=sum_x/len;
            sum_y=sum_y/len;
            index=index+1;
            slope_x(index)=sum_x-Junc_Pointx;
            slope_y(index)=sum_y-Junc_Pointy;
        end
    end
end
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