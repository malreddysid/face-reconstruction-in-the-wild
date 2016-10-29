imgpath='047640.jpg';
vjpath='047640_vj.txt';

load('model.mat','model');

DET=readvj(vjpath);
if ~isempty(DET)
	I=imread(imgpath);
        
	for j=1:size(DET,2)
        P=findparts(model,I,DET(:,j));
        imagesc(I);
        hold on;
        for k=1:size(P,2)
            plot(P(1,k),P(2,k),'y+','linewidth',2,'markersize',10);
            text(P(1,k)+2,P(2,k)+2,sprintf('%d',k),'color','y');
        end
        hold off;
        axis image;
        axis off;
        truesize;
        colormap(gray);
        pause;
	end
end
