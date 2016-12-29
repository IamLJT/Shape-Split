function [PVS,Contour_length, L]=GetPVS(aa,bb,start_,end_,Contour_length,pri)
%-----------------------------------------------------------
%Name:  [PVS,Contour_length]=GetPVS(aa,bb,start_,end_,Contour_length,pri)
%Dest:  获取分割线对应的视觉显著度
%Para:  start_,end_ 起始点、终止点序号
%       aa,bb 轮廓点坐标链表
%       Contour_length 轮廓长度
%       pri 该分叉点的优先级
%Return:PVS 分割线对应的视觉显著度
%       Contour_length 轮廓的等效长度
%       L 轮廓长度
%-----------------------------------------------------------
d=sqrt((aa(start_)-aa(end_))^2+(bb(start_)-bb(end_))^2);
[L,Contour_length]=GetContourLength(aa, bb, start_, end_,...
    Contour_length,pri);
PVS=sqrt((L^2)/(d^2)-1);
return

function [distance, Contour_length]=GetContourLength(aa, bb, start_, end_,...
    Contour_length,pri)
%-----------------------------------------------------------
%Name:  [distance, skle_length]=GetContourLength(aa, bb, start_, end_,skel_length)
%Dest:  获取轮廓长度
%Para:  start_,end_ 起始点、终止点序号
%       aa,bb 轮廓点坐标链表
%       Contour_length 轮廓长度
%       pri 该分叉点的优先级
%Return:distance 分割点对应的轮廓长度
%       Contour_length 轮廓长度
%-----------------------------------------------------------
len=length(aa);
left=0;
right=0;
if end_>start_
    left=start_;
    right=end_;
else
    left=end_;
    right=start_;
end

% 同时测试两边  （未成功）
% pl_tmp=[];
% pr_tmp=[];
% l_tmp=[];
% 
% pl_tmp(1)=left;
% pr_tmp(1)=right;
% temp0=right;
% right=left+len;
% left=temp0;
% pl_tmp(2)=left;
% pr_tmp(2)=right;

if (right-left+1)>len/2
    temp0=right;
    right=left+len;
    left=temp0;
end


[m,n]=size(Contour_length);
temp=[];        % 临时数组，存储当前优先级下的所有分割线
% if m>0
%     temp=find(Contour_length(:,4)<=pri);
% end

% for z=1:length(pl_tmp)
%     left=pl_tmp(z);
%     right=pr_tmp(z);
    distance=0;
    d=0;
    d_flag=0;
    i=left;
    while i<right
        pri_tmp=pri;
        j=i;
        k=j+1;
        flag=0;
        
        while pri_tmp>0
            if m>0
                temp=find(Contour_length(:,4)==pri_tmp);
            end
            pri_tmp=pri_tmp-1;
            if length(temp)>0
                for e=1:length(temp)
                    if (i>len&&i-len==Contour_length(temp(e),1)&&right-len>=Contour_length(temp(e),2))
                        d_flag=1;
                        distance=distance+Contour_length(temp(e),3);
                        i=Contour_length(temp(e),2)+len;
                        flag=1;
                        break;
                    elseif (i==Contour_length(temp(e),1)&&right>=Contour_length(temp(e),2))
                        if left==Contour_length(temp(e),1)&&right==Contour_length(temp(e),2)
                            continue;
                        end
                        d_flag=1;
                        distance=distance+Contour_length(temp(e),3);
                        i=Contour_length(temp(e),2);
                        flag=1;
                        break;
                    end
                end
            end
        end
        if flag==1
            continue;
        end
        if j>len
            j=j-len;
        end
        if k>len
            k=k-len;
        end
        distance=distance+sqrt((aa(k)-aa(j))^2+(bb(k)-bb(j))^2);
        i=i+1;
    end
%     if d_flag==0
        d=sqrt((aa(start_)-aa(end_))^2+(bb(start_)-bb(end_))^2);
%         l=d;
%     else
%         l=distance;
%     end
%     l_tmp(z,1)=d_flag;
%     l_tmp(z,2)=distance;
%     l_tmp(z,3)=l;
% end

% if l_tmp(1,2)<l_tmp(2,2)
%     left=pl_tmp(1);
%     right=pr_tmp(1);
%     l=l_tmp(1,3);
% else
%     left=pl_tmp(2);
%     right=pr_tmp(2);
%     l=l_tmp(2,3);
% end

isexist=0;
for i=1:m
    if Contour_length(i,1)==left&&Contour_length(i,2)==right
        isexist=1;
        if d_flag==0||Contour_length(i,3)>d
            Contour_length(i,3)=d;
        end
        break;
    end
end
if isexist==0
    index=m+1;
    Contour_length(index,1)=left;
    Contour_length(index,2)=right;
    Contour_length(index,3)=d;
    Contour_length(index,4)=pri;
end
return;