% Plot the residual of the partial regression of X (input - LHS matrix) and Y (output)
% at column s (time points saved). PCC Coefficients are calculated on these
% var: labels of the parameters varied in the X (as legend)
% The Title of the plot is the Pearson correlation coefficient of the
% transformed data, that is  the PRCC calculated on the original data.
% The p-value is also showed in the title
% by Simeone Marino, June 5 2007 %%

function PRCC_PLOT2(X,Y,PRCC_var,y_var,pldimx,pldimy,plnum,figurenum)
%pldymx - number of rows in plot
%pldymy- numver of columns
% plnum - order number of the plot
%figurenum - figure number
%Y=Y(s,:);
[a k]=size(X); % Define the size of LHS matrix
Xranked=rankingN(X);
Yranked=ranking1(Y);
for i=1:k  % Loop for the whole submatrices, Zi
    c1=['LHStemp=Xranked;LHStemp(:,',num2str(i),')=[];Z',num2str(i),'=[ones(a,1) LHStemp];LHStemp=[];'];
    eval(c1);
end
for i=1:k
    c2=['[b',num2str(i),',bint',num2str(i),',r',num2str(i),']= regress(Yranked,Z',num2str(i),');'];
    c3=['[b',num2str(i),',bint',num2str(i),',rx',num2str(i),']= regress(Xranked(:,',num2str(i),'),Z',num2str(i),');'];
    eval(c2);
    eval(c3);
end
for i=1:k
    c4=['r',num2str(i)];
    c5=['rx',num2str(i)];
    [r(i) p(i)]=corr(eval(c4),eval(c5));
    a=['[PRCC , p-value] = ' '[' num2str(r(i)) ' , '  num2str(p(i)) '].'];% ' Time point=' num2str(s-1)];
%     figure,plot((eval(c4)),(eval(c5)),'.'),Title(a),...
%             legend(PRCC_var{i}),xlabel(PRCC_var{i}),ylabel(y_var);%eval(c
%             6); donot plot the subfigures out

end

figure(figurenum)
subplot(pldimx,pldimy,plnum);
barh(r)
set(gca,'YLim',[.5 k+0.5]);% This automatically sets the SASHA CHANGED THIS
set(gca,'Xlim',[-1,1]);
% XLimMode to manual.

% Set XTick so that only the integer values that
% range from 0.5 - 12.5 are used.
set(gca,'YTick',1:k); % This automatically sets SASHA CAHNGED THIS from 6 to k
% the XTickMode to manual.

% Set the XTickLabel so that abbreviations for the
% labels are used.
set(gca,'yticklabels',PRCC_var,'fontsize',18); % ,'fontweight','b')%for \bf
%title('PRCC with respect to' y_var);
%xlabel('PRCC')
title(y_var,'Interpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
% figure
% bar(p);
% set(gca,'XLim',[.5 20.5]);
% set(gca,'XTick',[1:20])
% set(gca,'xticklabel',PRCC_var)
% %legend(y_var)
% ylabel('p-value');
% title(y_var);


% figure
% barh(r);
% set(gca,'yticklabel',PRCC_var)
% %title('PRCC with respect to' y_var);
% xlabel('PRCC')
% title(y_var);
% figure
% barh(p);
% set(gca,'yticklabel',PRCC_var)
% %legend(y_var)
% xlabel('p-value');
% title(y_var);

