init;

fprintf('running from cached face detections...\n');

[DETS,PTS,DESCS]=extfacedescs(opts,'../../data/George_W_Bush/George_W_Bush_0183.jpg',true);

fprintf(' DETS: %d x %d\n',size(DETS,1),size(DETS,2));
disp(DETS);
fprintf('  PTS: %d x %d x %d\n',size(PTS,1),size(PTS,2),size(PTS,3));
disp(PTS);
fprintf('DESCS: %d x %d\n',size(DESCS,1),size(DESCS,2));

if strcmp(computer,'PCWIN')

    pause;
    
    fprintf('running using face detector binary...\n');

    I=imread('047640.jpg');
    
    [DETS,PTS,DESCS]=extfacedescs(opts,I,true);
    
	fprintf(' DETS: %d x %d\n',size(DETS,1),size(DETS,2));
	fprintf('  PTS: %d x %d x %d\n',size(PTS,1),size(PTS,2),size(PTS,3));
	fprintf('DESCS: %d x %d\n',size(DESCS,1),size(DESCS,2));
end
