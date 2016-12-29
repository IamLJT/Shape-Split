function [x,y,sx,sy,Junc_p]=GetSkelRange(skel_dist,N_limitpoint)
%-------------------------------------
%Name:  [x,y,s]=GetSkelRange(skel_dist)
%Dest:  骨架区域划分
%Para:  skel_dist 骨架图像
%Return:start_s,end_s 起始点、终止点序号
%       sx,sy 轮廓区域
%       Junc_p 优先级
%-------------------------------------
[end_ps_y, end_ps_x]=FindEndPoints(skel_dist);
[b, a]=FindJunctionPoint(skel_dist,N_limitpoint);
Junc_p=zeros(length(a),1);
index_pri=1;        % 优先级数
x=[];
y=[];
sx=[];
sy=[];
skel_temp=1*skel_dist;
for i=1:length(a)
    skel_temp(b(i),a(i))=100;
end

[x,y,sx,sy,skel_temp,Junc_p]=FindSkelRange(end_ps_x, end_ps_y, ...
    x, y, sx, sy, skel_temp, a, b, index_pri, Junc_p);

while length(find(skel_temp==1))>length(a)+length(end_ps_x)&&index_pri<=max(Junc_p)
    for i=1:index_pri
        end_x=a(find(Junc_p==i));
        end_y=b(find(Junc_p==i));
    %     a_x=a(find(Junc_p==0));
    %     b_y=b(find(Junc_p==0));
        [x,y,sx,sy,skel_temp,Junc_p]=FindSkelRange(end_x, end_y, ...
            x, y, sx, sy, skel_temp, a, b, i+1, Junc_p);
    end
    index_pri=index_pri+1;
end
return;

function [x,y,sx,sy,skel_temp,Junc_p]=FindSkelRange(end_ps_x, end_ps_y, ...
    x, y, sx, sy, skel_temp, a, b, index_pri, Junc_p)
dx=[-1,-1,0,1,1,1,0,-1];
dy=[0,-1,-1,-1,0,1,1,1];
temp=1;
index=length(x);
[m,n]=size(skel_temp);
for i=1:length(end_ps_x)
    start_s=length(sx)+1;
    index_num=start_s;
    sx(index_num)=end_ps_x(i);
    sy(index_num)=end_ps_y(i);
    if skel_temp(end_ps_y(i),end_ps_x(i))==1
        skel_temp(end_ps_y(i),end_ps_x(i))=0;
    end
    cx=end_ps_x(i);
    cy=end_ps_y(i);
    isJuncPoint=0;
    while ~isJuncPoint
        FindPoint=0;
        flag=0;
        isjunc_near=0;
        temp_num=0;
        while ~FindPoint&&flag==0
            tx=cx+dx(temp);
            ty=cy+dy(temp);
            for j=1:length(a)
                if (a(j)-cx)^2+(b(j)-cy)^2<=2&&a(j)~=end_ps_x(i)&&b(j)~=end_ps_y(i)
                    isjunc_near=1;
                    break;
                end
            end
            if tx<=n&&tx>0&&ty<=m&&ty>0&&...
                    skel_temp(ty,tx)==1&&isjunc_near==0
                index_num=index_num+1;
                sx(index_num)=tx;
                sy(index_num)=ty;
                skel_temp(ty,tx)=0;
                FindPoint=1;
%                 for j=1:length(a)
%                     if (a(j)-tx)^2+(b(j)-ty)^2<=2
%                         Junc_p(j)=1;
%                         isJuncPoint=1;
%                         index_num=index_num+1;
%                         sx(index_num)=a(j);
%                         sy(index_num)=b(j);
%                         end_s=index_num;
%                         break;
%                     end
%                 end
                cx=tx;
                cy=ty;
            elseif tx<=n&&tx>0&&ty<=m&&ty>0&&...
                    skel_temp(ty,tx)==100
                index_num=index_num+1;
                end_s=index_num;
                sx(index_num)=tx;
                sy(index_num)=ty;
                FindPoint=1;
                isJuncPoint=1;
                % 优先级划分
                for j=1:length(a)
                    if Junc_p(j)==0&&a(j)==tx&&b(j)==ty
                        Junc_p(j)=index_pri;
                        break;
                    end
                end
            else
                temp=temp+1;
                temp_num=temp_num+1;
                if temp>8
                    temp=temp-8;
                end
                if index_num-start_s>0
                    if temp_num==3
                        temp=temp-5;
                        temp_num=-2;
                        if temp<=0
                            temp=temp+8;
                        end
                    end
                else
                    if temp_num==8
                        temp_num=0;
                    end
                end
                if temp_num==0
                    flag=1;
                end
            end
        end
        if FindPoint==0||flag==1
            end_s=index_num;
        end
        % 若只有1个元素或者首尾都不是分叉点
        if (FindPoint==0&&cx==end_ps_x(i)&&cy==end_ps_y(i))||(flag==1)
        	isJuncPoint=1;
        end
    end
    
    if end_s~=start_s
        index=index+1;
        x(index)=start_s;
        y(index)=end_s;
    end
end
return

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