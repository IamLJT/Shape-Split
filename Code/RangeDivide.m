function range=RangeDivide(skel_dist, aa, bb, contour)
%-----------------------------------------------------------
%Name:  range=RangeDivide(skel_dist, aa, bb, contour)
%Dest:  ���򻮷�
%Para:  skel_dist �Ǽ�ͼ��
%       aa,bb ��������������
%       contour ������ͼ��
%Return:range ��������
%-----------------------------------------------------------
[end_ps_x,end_ps_y]=FindEndPoints(skel_dist);
[dist,lab]=bwdist(contour);         %   �õ�����任����
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
%Dest:  Ѱ�ҹǼ���β�˵ĵ�
%Para:  skel_dist �Ǽ�ͼ��
%Return:end_ps_x,end_ps_y β�˵�����
%-----------------------------------------------------------
[m,n]=size(skel_dist);
out=BOHitOrMiss(skel_dist, 'end');
[end_ps_y, end_ps_x]=Lab2Pos(find(1==out), m, n);
return