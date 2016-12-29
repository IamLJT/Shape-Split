function [a, b, skel_dist]=FindJunctionPoint(skel_dist,len)
%--------------------------------------------
%Name:  [aa, bb]=FindJunctionPoint(skel_dist)
%Dest:  寻找骨架上的分叉点，并对骨架上非交叉点进行修正
%Para:  skel_dist  骨架图像
%       len 骨架延长阈值
%Return:aa,bb  分叉点的坐标
%       bw 修正后的骨架
%--------------------------------------------
xx=[-1,-1,0,1,1,1,0,-1];
yy=[0,-1,-1,-1,0,1,1,1];
[m, n]=size(skel_dist);
x=[];
y=[];
delete_x=[];
delete_y=[];
delete_xynum=0;
index=1;
temp_p=[];
for i=1:m
    for j=1:n
        if skel_dist(i,j)==0
            continue;
        end
        delete_x=[];
        delete_y=[];
        delete_xynum=0;
        num=0;
        flag=0;
        begin=0;
        c=i+xx(1);
        d=j+yy(1);
        if ~(c<=0 || c>m || d<=0 || d>n) && skel_dist(c,d)>0
            [res,x,y]=isSkelEdge(i,j,c,d,skel_dist,len);
            if res>0
                flag=1;
                begin=1;
                num=num+1;
            end
            if length(x)>0
                delete_xynum=delete_xynum+1;
                l=length(x);
                st=length(delete_x);
                delete_x(st+1:st+l)=x(:);
                delete_y(st+1:st+l)=y(:);
            end
        end
        for k=2:length(xx)
            c=i+xx(k);
            d=j+yy(k);
            if (c<=0 || c>m || d<=0 || d>n)
                continue;
            end
            if skel_dist(c,d)>0 && flag==0
                [res,x,y]=isSkelEdge(i,j,c,d,skel_dist,len);
                if res>0
                    num=num+1;
                    flag=1;
                    temp_p(num)=k;
                end
                if length(x)>0
                    delete_xynum=delete_xynum+1;
                    l=length(x);
                    st=length(delete_x);
                    delete_x(st+1:st+l)=x(:);
                    delete_y(st+1:st+l)=y(:);
                end
            elseif skel_dist(c,d)==0
                flag=0;
            else
                continue;
            end
        end
        if flag==1 && begin==1
            num=num-1;
        end
        if delete_xynum>0&&delete_xynum+num>=3
            for e=1:length(delete_x)            
                skel_dist(delete_x(e),delete_y(e))=0;
            end
        end
        if num>=3
            a(index)=i;
            b(index)=j;
            index=index+1;
        end
%         if num==2 % 未成功
%             if IsJuncPointInTwo(skel_dist,i,j,10,temp_p)>0
%                 a(index)=i;
%                 b(index)=j;
%                 index=index+1;
%             end
%         end
    end
end
return; 

function [res,x,y]=isSkelEdge(i,j,c,d,skel_dist,k)
%   判断是否属于骨架上的边

x=[];   % 骨架上的x、y坐标
y=[];

xx=[-1,-1,0,1,1,1,0,-1];
yy=[0,-1,-1,-1,0,1,1,1];
[m,n]=size(skel_dist);
res=1;
index=1;    % 骨架坐标的序号
x(index)=c;
y(index)=d;
dx=c-i;
dy=d-j;
temp=1;
for e=1:length(xx)
    if dx==xx(e)&&dy==yy(e)
        temp=e;
        break;
    end
end
for a=1:k-1
    isFindPoint=0;
    flag=0;
    temp_num=0;
    while ~isFindPoint&&flag==0
        e=c+xx(temp);
        f=d+yy(temp);
        if e<=0 || e>m || f<=0 || f>n || skel_dist(e,f)==0
            temp=temp+1;
            if temp==9
                temp=1;
            end
            temp_num=temp_num+1;
            if temp_num==3
                temp_num=-2;
                temp=temp-5;
                if temp<=0
                    temp=temp+8;
                end
            end
        else
            isFindPoint=1;
            c=e;
            d=f;
            index=index+1;
            x(index)=c;
            y(index)=d;
            continue;
        end
        if temp_num==0
            flag=1;
        end
    end
    res=res&isFindPoint;
    if res==0
        break;
    end
end
if res==1
    x=[];
    y=[];
end
return;

function res=IsJuncPointInTwo(skel,i,j,N,temp_p)
%-----------------------------------------
%Name:  res=IsJuncPointInTwo(skel,i,j,N)
%Dest:  判断是否斜率突变
%Para:  skel 骨架图像
%       i,j 测试点坐标
%       N 测试点数
%Return:res 是否突变点
%-----------------------------------------
res=0;
xx=[-1,-1,0,1,1,1,0,-1];
yy=[0,-1,-1,-1,0,1,1,1];
sum_x=[];
sum_y=[];
[m,n]=size(skel);
for index=1:2
    t_n=N;
    temp=temp_p(index);
    sum_x(index)=0;
    sum_y(index)=0;
    c=i;
    d=j;
    while t_n>0
        t_n=t_n-1;
        isFindPoint=0;
        flag=0;
        temp_num=0;
        while ~isFindPoint&&flag==0
            e=c+xx(temp);
            f=d+yy(temp);
            if e<=0 || e>m || f<=0 || f>n || skel(e,f)==0
                temp=temp+1;
                if temp==9
                    temp=1;
                end
                temp_num=temp_num+1;
                if temp_num==3
                    temp_num=-2;
                    temp=temp-5;
                    if temp<=0
                        temp=temp+8;
                    end
                end
            else
                isFindPoint=1;
                c=e;
                d=f;
                sum_x(index)=sum_x(index)+c;
                sum_y(index)=sum_y(index)+d;
                continue;
            end
            if temp_num==0
                flag=1;
            end
        end
        if flag==1
            break;
        end
    end
    if t_n>0
        res=0;
        return;
    end
    sum_x(index)=sum_x(index)/N;
    sum_y(index)=sum_y(index)/N;
end
theta1=atan2(sum_y(1)-j,sum_x(1)-i);
theta2=atan2(sum_y(2)-j,sum_x(2)-i);
if abs(theta1-theta2)<2*pi/3||abs(theta1-theta2)>5*pi/3
    res=1;
end
return;
