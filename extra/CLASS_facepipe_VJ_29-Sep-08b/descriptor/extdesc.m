function fd = extdesc(par,I,P,debug)

if nargin<4
    debug=false;
end

if ndims(I)==3
    I=rgb2gray(I);
end
I=double(I);

r=par.r;
scl=par.scl;
VP=par.VP;
Pmu=par.Pmu;
Pmu(3,:)=1;

[X0,Y0]=meshgrid(-r:r,-r:r);
R2=X0.*X0+Y0.*Y0;
M=R2<=r*r;
XY0=[X0(M)*scl Y0(M)*scl]';

NC8=nchoosek(1:9,8)';

emin=inf;
for c=1:size(NC8,2)
    A=Pmu(:,NC8(:,c))';
    B=P(:,NC8(:,c))';
    Tc=(A\B)';
    P1=Tc*Pmu(:,NC8(:,c));
    D=P1-P(:,NC8(:,c));
    e=sum(sqrt(sum(D.*D)));
    if e<emin
        emin=e;
        T=Tc;
    end
end
T=T(1:2,1:2);

[U,S,V]=svd(T);
s=mean(diag(S));

lev=max(floor(log(s)/log(1.5)),0)+1;
ps=1.5^(lev-1);
s=s/ps;
T=[1/ps 0 ; 0 1/ps]*T;

PYR=pyramid15(I,lev,false);
J=PYR{lev};

P0=zeros(2,size(VP,2));
for j=1:size(VP,2)
    P0(:,j)=mean(P(:,VP(VP(:,j)>0,j)),2);            
end
P0=(P0-1)/ps+1;

FD=zeros(size(XY0,2),size(VP,2));
for j=1:size(VP,2)
    fdj=vgg_interp2(J,T(1,:)*XY0+P0(1,j),T(2,:)*XY0+P0(2,j),'linear',0)';
    fdj=fdj-mean(fdj);
    sd=std(fdj);
    if sd<=0
        sd=1;
    end
    fdj=fdj/sd;
    FD(:,j)=fdj;
end

fd=FD(:);

if debug
    for j=1:size(VP,2)
        subplot(ceil(sqrt(size(VP,2))),ceil(size(VP,2)/ceil(sqrt(size(VP,2)))),j);
        V=ones(size(M))*nan;
        V(M)=FD(:,j);
        imagesc(V,[-3 3]);
        axis image;
        axis off;
    end
    colormap gray;
end
