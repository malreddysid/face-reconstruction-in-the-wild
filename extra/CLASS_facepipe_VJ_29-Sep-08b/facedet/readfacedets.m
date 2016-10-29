function DET = readfacedets(path)

try
    T=dlmread(path);
    n=T(1);
    if n
        BB=T(2:end,:)';
        DET=[(BB(1,:)+BB(2,:))/2 ; (BB(3,:)+BB(4,:))/2 ; (BB(2,:)-BB(1,:))/2];
        DET(4,:)=1;
    else
        DET=[];
    end
catch
    DET=[];
end
