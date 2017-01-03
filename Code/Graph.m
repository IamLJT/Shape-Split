close all;
figure(2);
[row,col]=size(I3);
res_img=zeros(row,col,3);
for i=1:row
    for j=1:col
        if I3(i,j)~=1&&bw(i,j)~=1
            res_img(i,j,:)=255;
        end
    end
end
imshow(res_img);
hold on;
[m,n]=size(SplitLines);

[pixel_y_p,pixel_x_p]=Lab2Pos(pixel_p,row,col);

tmp_Contour=I3;
len_C=length(aa);
tmp_img=zeros(row,col);
flag_img=zeros(row,col);
color_index=0;
r_pp=0;
l_pp=0;
for i=1:max(SplitLines(:,3))+1
    for j=1:m
        if SplitLines(j,3)==-1||SplitLines(j,3)~=i
            continue;
        end
        tmp_img(:,:)=0;
        l_p=SplitLines(j,1);
        r_p=SplitLines(j,2);
        r_pp=r_p;
        l_pp=l_p;
        if r_p<l_p
            tmp=r_p;
            r_pp=l_p;
            l_pp=tmp;
        end
        if r_pp-l_pp>len_C/2
            tmp=r_pp;
            r_pp=l_pp+len_C;
            l_pp=tmp;
        end
        for j_=l_pp:r_pp
            k=j_;
            if k>length(aa)
                k=k-length(aa);
            end
            tmp_img(aa(k),bb(k))=1;
        end
        start_=0;
        end_=0;
        s_flag=0;
        isInf=0;        % 斜率标记参数，1为垂直，2为水平
        tmp_slope=0;   % 分割线参数
        tmp_b=0;
        
        if aa(r_p)-aa(l_p)==0
            isInf=1;
        elseif bb(r_p)-bb(l_p)==0
            isInf=2;
        else
            tmp_slope=(bb(r_p)-bb(l_p))/(aa(r_p)-aa(l_p));
            tmp_b=bb(r_p)-aa(r_p)*tmp_slope;
        end
        if abs(bb(r_p)-bb(l_p))>abs(aa(r_p)-aa(l_p))
            s_flag=1;
            if bb(r_p)-bb(l_p)>0
                start_=bb(l_p);
                end_=bb(r_p);
            else
                start_=bb(r_p);
                end_=bb(l_p);
            end
        else
             s_flag=0;
            if aa(r_p)-aa(l_p)>0
                start_=aa(l_p);
                end_=aa(r_p);
            else
                start_=aa(r_p);
                end_=aa(l_p);
            end
        end
        for k=start_:end_
            if isInf==1
                tmp_img(aa(l_p),k)=1;
            elseif isInf==2
                tmp_img(k,bb(r_p))=1;
            elseif s_flag==0
                tmp_img(k,round(k*tmp_slope+tmp_b))=1;
            else
                tmp_img(round((k-tmp_b)/tmp_slope),k)=1;
            end
        end
        If2 = imfill(tmp_img,'holes');  % 区域填充
        temp=find(If2==1);
        [temp_y, temp_x]=Lab2Pos(temp,row,col);
        color_index=color_index+1;
        color_tmp=[mod(abs(255-(color_index-1)*40),256)/255,mod((color_index-1),256)*40/255,...
            mod((color_index-1)*40,256)/255];
        for ii=1:length(temp)
            if flag_img(temp_x(ii),temp_y(ii))==1
                continue;
            end
            flag_img(temp_x(ii),temp_y(ii))=1;
            if I3(temp_x(ii),temp_y(ii))~=1&&...
                    bw(temp_x(ii),temp_y(ii))~=1
                res_img(temp_x(ii),temp_y(ii),:)=color_tmp;
            end
        end
%         figure(3);
%         imshow(If2);
%         figure(2);
%         imshow(res_img);
    end
end

color_index=color_index+1;
color_tmp=[abs(255-(color_index-1)*40)/255,(color_index-1)*40/255,...
    (color_index-1)*40/255];
for i=1:length(pixel_p)
    if I3(pixel_x_p(i),pixel_y_p(i))~=1&&...
            bw(pixel_x_p(i),pixel_y_p(i))~=1&&...
            flag_img(pixel_x_p(i),pixel_y_p(i))~=1
        res_img(pixel_x_p(i),pixel_y_p(i),:)=color_tmp;
    end
end
imshow(res_img);

figure(2);
for i=1:m
    if SplitLines(i,3)~=-1
        l_p=SplitLines(i,1);
        r_p=SplitLines(i,2);
        plot([bb(l_p),bb(r_p)],[aa(l_p),aa(r_p)],'-k','linewidth',1.5);
    end
end
