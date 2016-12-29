function [slope_x, slope_y]=GetJuncSlope2(skel_dist, start_s, end_s, sx, sy, Junc_Pointx, Junc_Pointy, dist, N)
%-------------------------------------
%Name:  [slope_x, slope_y]=GetJuncSlope2...
%           (start_s, end_s, sx, sy, Junc_Pointx, Junc_Pointy)
%Dest:  �ֲ��б�ʻ�ȡ
%Para:  start_s,end_s �Ǽܷ�֧��ʼ�㡢��ֹ�����
%       sx,sy ��������
%       Junc_Pointx,Junc_Pointy �ֲ��
%       dist ��������任����
%       N �Ǽܷ�֧��������
%Return:slope_x,slope_y б�ʻ�ȡ
%-------------------------------------
index=0;
slope_x=[];
slope_y=[];
[end_ps_x,end_ps_y]=FindEndPoints(skel_dist);
for i=1:length(start_s)
    if start_s(i)~=end_s(i)
        %   �ж��Ƿ�˵��������ֲ��
        st_e=0;     % �Ƿ�����˵�
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
                % �������С���������Բ�뾶�ķֲ��ȥ�����о�����
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
%Dest:  Ѱ�ҹǼ���β�˵ĵ�
%Para:  skel_dist �Ǽ�ͼ��
%Return:end_ps_x,end_ps_y β�˵�����
%-----------------------------------------------------------
[m,n]=size(skel_dist);
out=BOHitOrMiss(skel_dist, 'end');
[end_ps_y, end_ps_x]=Lab2Pos(find(1==out), m, n);
return