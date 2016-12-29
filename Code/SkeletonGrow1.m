function skltn = SkeletonGrow1(bw,ro,mark)
%---------------------------------------
%Name:  skltn = SkeletonGrow(bw,ro)
%Desc:  �Ӷ�ֵͼ�л������ĹǼ�
%       bw��һ��n��n�ľ��󣬷�0���ʾ��
%       ���λ��
%Para:  bw����n��n�ľ��󣬷�0���ʾ����
%           ��λ��
%Return:skltn������bwͬά�ľ��󣬷�0���
%        ʾ�Ǽܵ�,����ֵ��ʾ���Բ�İ뾶
%--------------------------------------
[m,n] = size(bw);
skltn = zeros(m,n);
%��һ�������о���任
[dist,lab] = bwdist(bw);          %dist����任�������lab�����ȵ�һά�������

% the star point of the skeleton
root = find(dist == max(max(dist)));             %find���ؾ���任���ֵ�������ȱ��
root = root(1);                                  %�Ǽ���ʼ�㣬ȡ�����ȱ���еĵ�һ��

%accsee matrix   ��ȡ����
bAccess = zeros(m,n);

curPoint = [0,0];
[curPoint(2),curPoint(1)] = Lab2Pos(root,m,n);    %�ɱ�Ż�ȡ����ʼ���������

skltn(curPoint(1),curPoint(2)) = dist(curPoint(1),curPoint(2));   %dist���������á��õ���ʼ���ӵ�ľ���任�����е�ֵ��������Բ�뾶��
bAccess(curPoint(1),curPoint(2)) = 1;                                %�Ǽܶ���Ҷ�ֵ����Ϊ1��

%access stack                  ���ʶ�ջ
AccessStack = [curPoint];            %�Ӹ����꿪ʼ��ջ

% from the start point, check the 4-adjent points and the 8-adjent points
while (length(AccessStack) ~= 0);
    curPoint = AccessStack(1,:);
    [tm,tn] = size(AccessStack);
    AccessStack = AccessStack(2:tm,:);
    nAdj = 0;
    for i = max(curPoint(1)-1,1):min(curPoint(1)+1,m);
        for j = max(curPoint(2)-1,1):min(curPoint(2)+1,n);
            if bAccess(i,j) == 0;
                skltn(i,j) = CheckSkeleton1(bw,dist,lab,i,j,ro,mark);
                if skltn(i,j) ~= 0;
                    bAccess(i,j) = 1;
                    nAdj = nAdj+1;
                    AccessStack = [[i,j];AccessStack];
                else
                    bAccess(i,j) = -1;
                end;
            end;
        end;
    end;
    
end;
     
