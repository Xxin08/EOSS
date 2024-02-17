clc;clear;close all; warning('off')
addpath algorithms\EOSS\;

disp(['EOSS-PW']);
for k=1:3
    if k==1
        addpath dataset\VI\
    elseif k==2
        addpath dataset\OS\
    else
        addpath dataset\OM\
    end
    RES=[];
for i = 1:25
    disp(['k£º',num2str(k) '  Pair£º',num2str(i)]);
    str1=['Pair' num2str(i) '_1.tif'];
    str2=['Pair' num2str(i) '_2.tif'];
    gtstr =['Gt' num2str(i) '.txt'];

    if exist(str1,'file')==0
        continue;
    end
    gt=load(gtstr);
    im1 = uint8(imread(str1));
    im2 = uint8(imread(str2));

    imwrite(im1,'.\algorithms\EOSS\1.tif');
    imwrite(im2,'.\algorithms\EOSS\2.tif');
    
    exe='.\algorithms\EOSS\EOSSPW.exe';
    cmd = [exe ' ' '.\algorithms\EOSS\1.tif' ' ' '.\algorithms\EOSS\2.tif' ' ' '.\algorithms\EOSS' ' ' '108' ' ' '500'];
    t1=clock();
    system(cmd);
    t2=clock();
    time=etime(t2,t1);
    matches = load('.\algorithms\EOSS\matches.txt');
    
    matchedPoints1 = matches(:,1:2);
    matchedPoints2 = matches(:,3:4);

    H=gt;
    Y_=H*[matchedPoints1';ones(1,size(matchedPoints1,1))];
    Y_(1,:)=Y_(1,:)./Y_(3,:);
    Y_(2,:)=Y_(2,:)./Y_(3,:);
    E=sqrt(sum((Y_(1:2,:)-matchedPoints2').^2));
    inliersIndex=E<3;
    cleanedPoints1 = matchedPoints1(inliersIndex, :);
    cleanedPoints2 = matchedPoints2(inliersIndex, :);
    [cleanedPoints2,IA] = unique(cleanedPoints2,'rows');
    cleanedPoints1 = cleanedPoints1(IA,:);
    [cleanedPoints1,IB] = unique(cleanedPoints1,'rows');
    cleanedPoints2 = cleanedPoints2(IB,:);
    cleanedPoints=[cleanedPoints1 cleanedPoints2];
    
    cleanedPoints = double(cleanedPoints);
    Y_=H*[cleanedPoints(:,1:2)';ones(1,size(cleanedPoints,1))];
    Y_(1,:)=Y_(1,:)./Y_(3,:);
    Y_(2,:)=Y_(2,:)./Y_(3,:);
    E=sqrt(sum((Y_(1:2,:)-cleanedPoints(:,3:4)').^2));
    if length(E)<=10
        rmse = 20;
    else
        rmse = sqrt(sum(E.^2)/size(E,2));
    end
    disp(['RMSE: ',num2str(rmse) '     CMN: ',num2str(length(E)) '     Time: ',num2str(time)]);
    timeres = double([time rmse size(cleanedPoints,1) size(matchedPoints1,1)]);
    RES = [RES;timeres];
end
RESm = mean(RES);

end
disp(['']);







