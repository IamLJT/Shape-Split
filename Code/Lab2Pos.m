function [x,y] = Lab2Pos(lab,m,n)
%---------------------------------------
%Name:  [x,y] = Lab2Pos(lab,n)
%Desc:  �ɱ�Ż��Ԫ���ھ����е�������
%Para:  lab  Ԫ�ر�ţ������ȵ�˳����
%       m,n  �����ά  
%Return:x,y  Ԫ���ھ����е�������
%---------------------------------------
[y, x] = ind2sub([m, n], lab);
x = double(x);
y = double(y);