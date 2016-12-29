function [a, b, p]=CreateSplitPoint(range, aa, bb, Junc_Pointx, Junc_Pointy)
%-----------------------------------------------------------
%Name:  [a, b]=CreateSplitPoint(skel_dist, I0, Junc_Point)
%Dest:  ���ָ��
%Para:  skel_dist �Ǽ�ͼ��
%       aa,bb ����ͼ��
%       Junc_Pointx,Junc_Pointy �ֲ������
%Return:a,b �ָ������
%       p �ָ�������������е�λ��
%-----------------------------------------------------------
k=0;
for i=1:length(range)
    start_p=range(i);
    if i==length(range)
        end_p=range(1)-1;
    else
        end_p=range(i+1)-1;
    end
    [xx,yy,pos]=FindClosestPoint(aa,bb,start_p,end_p,Junc_Pointx,Junc_Pointy);
    k=k+1;
    a(k)=xx;
    b(k)=yy;
    p(k)=pos;
end
return;

function [xx,yy,pos]=FindClosestPoint(aa,bb,start_p,end_p,Junc_Pointx,Junc_Pointy)
%-----------------------------------------------------------
%Name:  [xx,yy]=FindClosestPoint(aa,bb,start,end,Junc_Pointx,Junc_Pointy)
%Dest:  Ѱ�������ֶ��ھ���ֲ������ĵ�
%Para:  skel_dist �Ǽ�ͼ��
%       aa,bb ����ͼ�ε���������
%       start_p,end_p �����ϵ���ʼ�����ֹ�����
%       Junc_Pointx,Junc_Pointy �ֲ������
%Return:xx,yy �ָ������
%       pos �ָ�������������е�λ��
%-----------------------------------------------------------
min_p_x=aa(start_p);
min_p_y=bb(start_p);
min_d=(min_p_x-Junc_Pointx)*(min_p_x-Junc_Pointx)+...
    (min_p_y-Junc_Pointy)*(min_p_y-Junc_Pointy);
pos=start_p;
xx=min_p_x;
yy=min_p_y;
if end_p<start_p
    end_p=length(aa)+end_p;
end
for i=start_p:end_p
    j=i;
    if j>length(aa)
        j=j-length(aa);
    end
    if (aa(j)-Junc_Pointx)*(aa(j)-Junc_Pointx)+...
            (bb(j)-Junc_Pointy)*(bb(j)-Junc_Pointy)<min_d
        xx=aa(j);
        yy=bb(j);
        pos=j;
        min_d=(aa(j)-Junc_Pointx)*(aa(j)-Junc_Pointx)+...
            (bb(j)-Junc_Pointy)*(bb(j)-Junc_Pointy);
    end
end

return