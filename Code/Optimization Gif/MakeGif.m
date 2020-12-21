% uiopen('C:\Users\19095\Documents\ECE251C\optimization_record_500_BEATBASED_length8.csv',1);
% uiopen('C:\Users\19095\Documents\ECE251C\optimization_record_250CORRECTDATA_length8.csv',1);
A = table2array(optimizationrecord500BEATBASEDlength8);

[m,~] = max(A(:,9));

h = figure();
filename = '500_optim_clip_quick.gif';
for i = 1:3:150
    clf
   T = A((40*i)+2,1:8);
   [HiD, LoD] = myWaveletGenerator(T);
   subplot(1,2,1)
   stem(T)
   title('Theta Values')
   
   yticks([pi/4 pi/2 3*pi/4 pi 5*pi/4 3*pi/2 7*pi/4 2*pi])
   yticklabels({'^{\pi}/_{4}','^{\pi}/_{2}','^{3\pi}/_{4}','\pi','^{5\pi}/_{4}','^{3\pi}/_{2}','^{7\pi}/_{4}','2\pi'})
   
   xticks([1 2 3 4 5 6 7 8])
   xticklabels({'\theta1','\theta2','\theta3','\theta4','\theta5','\theta6','\theta7','\theta8'})
   ylim([0,2*pi])

   subplot(1,2,2)
   stem(LoD)
   t = ['accuracy = ', string(A((40*i)+2,9))];
   title(t)
   ylim([-1,1])
   
   sgtitle(['Iteration #', string(i)])
   drawnow
   
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    
    
    if i == 1 
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
        imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
   
    
    
end