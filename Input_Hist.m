tw = 100;% msec
DBS_indx = k_dbs:K_inc:L;%(10:1/Fs_DBS:T)*1e3/dt;% in samples
STC_inp = zeros(2*tw/dt+1,length(DBS_indx)-1);
for k = 1:length(DBS_indx)-1
    STC_inp (:,k) = I_total(DBS_indx(k)-tw/dt:DBS_indx(k)+tw/dt);%FG_mix(DBS_indx(k)-tw/dt:DBS_indx(k)+tw/dt);% , 
end

figure; plot(-tw:dt:tw,mean(STC_inp,2),'k')
% figure; plot(-tw:dt:tw,std(STC_inp',1),'k')
% 
% figure; plot(-tw:dt:tw,STC_inp,'k')
%% Plot
indx_V = k_dbs - 2e3/dt:k_dbs + 2e3/dt;
figure; plot(dt*indx_V,V_(indx_V),'k')