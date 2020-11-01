clear all
%% Initial Parameters of simulation
dt = 0.1; % sampling time (msec)
T = 20; % Total time (Sec)
tt = 0:dt:T*1e3;
L = length(tt);
param.tStop = T*1e3; %(msec)
param.dt = dt;
V = zeros(length(tt),1000);
%% Access to Pre-synaptic neurons. Spike times of 1000 neurons (average firing = 7 Hz) were saved in Noise_FR.txt 
A_ = dlmread('Noise_FR.txt'); % the rows show the spike time (as it is a matrix, some times are zeros).
%--- Build the spike binary
spTime_indx = A_'/dt;
F_binary = zeros(size(V));
for k=1:size(F_binary,2)
    indx = [];
    indx = find(spTime_indx(:,k)>0 & spTime_indx(:,k)<L);
    F_binary(floor(spTime_indx(indx,k)),k) = 1;
end
figure; plot(tt,F_binary(:,1))
hold on,
plot(tt,F_binary(:,100),'k')
xlabel('time (msec)')
ylabel('spike (binary)')
title('Examples of firing activity of two presynaptic neuons')
%% Setting DBS and Synaptic parameters
Fs_DBS = 5;% Hz
activation_percentage = 1;
perc_facilitation = 0.3;
perc_psudue = 0.3;  
A = 1;
indx_pool = 1:size(F_binary,2);
%--- For excitatory synapses
Trial_num_Exc = 50;
Trial_num = Trial_num_Exc;
indx_Exc =indx_pool(randperm(length(indx_pool),Trial_num_Exc)); % randomly selecting indecies from the pool of data
V_sp = F_binary(:,indx_Exc);
tau_syn = 3;% 
Delay = floor((0 + randn(1,Trial_num))/dt); Delay(Delay<0) = 0; % index
tau_f_Fac = 670; tau_d_Fac = 138; U_Fac = 0.09; % For Excitatory & Facilitatory Synapses
tau_f_Dep = 17; tau_d_Dep = 671; U_Dep = 0.5; % For Excitatory & Depressing Synapses
tau_f_Psu = 326; tau_d_Psu = 329; U_Psu = 0.29; % For Excitatory & Psudue Linear Synapses

run DBS_Plasticity
I_Exc = sum(I_cont_delay,2);%sum(I_cont,2);
%--- For inhibitory synapses
Trial_num_Inh = 450;
indx_remained = setdiff(indx_pool,indx_Exc);
indx_Inh =indx_remained(randperm(length(indx_remained),Trial_num_Inh));
V_sp = F_binary(:,indx_Inh);
tau_syn = 10;% 
Trial_num = Trial_num_Inh;
Delay = floor((0 + randn(1,Trial_num))/dt);  Delay(Delay<0) = 0;% index
tau_f_Fac = 376; tau_d_Fac = 45; U_Fac = 0.016; % For Inhibitory & Facilitatory Synapses
tau_f_Dep = 21; tau_d_Dep = 706; U_Dep = 0.25; % For Inhibitory & Depressing Synapses
tau_f_Psu = 62; tau_d_Psu = 144; U_Psu = 0.29; % For Inhibitory & Psudue Linear Synapses

run DBS_Plasticity
I_Inh = sum(I_cont_delay,2);%sum(I_cont,2);
w_exc = 1.5; % 
w_inh = 1.00 ;
I_total = 4*(w_exc*I_Exc - w_inh*I_Inh);
%% Noise and LIF model
I_bias = 55;
a2 = 10; % pA as the std of noise
eta = OUprocess(5, param);
I_tot = I_bias + 1*I_total + a2*eta;
figure; plot(tt,I_tot)
ylabel('Current (pA)')
xlabel('Time (msec)')

tau_V = 10;
R = 1; %Mohm
EL = -60;
V_rest = -70;
V_th = -40;
V_ = LIF_Simple(I_tot, R, tau_V, V_th, dt);
figure; plot(tt,V_)
ylabel('Voltage (mV)')
xlabel('Time (msec)')
%% Plots for Current and membrane potentials (different time scales)
indx = k_dbs - 1e3/dt:k_dbs + 1e3/dt;
figure; plot(dt*indx,I_total(indx),'k')
xlabel('Time (msec)')
ylabel('Current (pA)')
title('Total Pre-synaptic Current')

indx_V = k_dbs - 2e3/dt:k_dbs + 2e3/dt;
figure; plot(dt*indx_V,V_(indx_V),'k')
axis([dt*indx_V(1) dt*indx_V(end) -100 50])
ylabel('Voltage (mV)')
xlabel('Time (msec)')
title('Neuron Response (Membrane Potetial)')
