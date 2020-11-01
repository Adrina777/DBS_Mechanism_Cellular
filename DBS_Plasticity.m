 
tspk = zeros(1,Trial_num);
% --- Depression mode: [tau_dep, tau_fac, U] = [250, 50, 0.45]
tau_D = tau_d_Dep*ones(1,Trial_num); % msec --> This will comprise both Depression dominant & Facilitation Dominant states
tau_F = tau_f_Dep*ones(1,Trial_num);
U = U_Dep*ones(1,Trial_num);

% --- Potentiation mode: [tau_dep, tau_fac, U] = [50, 200, 0.05]
facil = floor(perc_facilitation*Trial_num);

tau_D(1,1:facil) = tau_d_Fac*ones(1,facil); % msec --> This will comprise both Depression dominant & Facilitation Dominant states
tau_F(1,1:facil) = tau_f_Fac*ones(1,facil);
U(1,1:floor(perc_facilitation*Trial_num)) = U_Fac;

% --- Psudeu Linear mode: [tau_dep, tau_fac, U] = [50, 200, 0.05]
ps_lin = floor(perc_psudue*Trial_num);

tau_D(1,1+facil:facil + ps_lin) = tau_d_Psu*ones(1,ps_lin); % msec --> This will comprise both Depression dominant & Facilitation Dominant states
tau_F(1,1+facil:facil + ps_lin) = tau_f_Psu*ones(1,ps_lin);
U(1,1+facil:facil + ps_lin) = U_Psu;
%%
R_disc = ones(1,Trial_num);
u_disc = zeros(1,Trial_num);
I_disc = zeros(1,Trial_num);

R_cont = zeros(L,Trial_num);
u_cont = zeros(L,Trial_num);
I_cont = zeros(L,Trial_num);
I_cont_delay = zeros(L,Trial_num);

R_cont(1,:) = 1;
u_cont(1,:) = 0;
%% Total presynaptic input (Excitation + Inhibition) induced by both spikes and DBS pulses
k = 1;
k_dbs = 10*1e3/dt + 0; % or any start time for DBS
k_sp = 2;
K_inc = floor(1e3/dt/Fs_DBS);
Delta_syn = zeros(1,Trial_num);
for t=0:dt:T*1e3
    
    indx_active = find( V_sp(k,:)==1 );
    Delta_syn(indx_active) = 1;
    if (k>=k_dbs && ~mod(k,K_inc))
        indx_active = 1:activation_percentage*Trial_num;
        Delta_syn(indx_active) = 1;
    end
    
        if tspk(indx_active)==0
            tspk(indx_active) = t;
        end
    
        u_cont(k,:) = u_disc .* exp(- (t-tspk) ./ tau_F ) + Delta_syn .* (U .*(1 - u_disc.*exp(- (t-tspk) ./ tau_F ))); % T by Trial_num
           
        R_cont(k,:) = R_disc .* (1 - Delta_syn.*u_cont(k,:)) .* exp(- (t-tspk) ./ tau_D ) + 1 - exp(- (t-tspk) ./ tau_D );
           
        I_cont(k,:) = I_disc .* exp(- (t-tspk) ./ tau_syn ) + A * Delta_syn .* u_cont(k,:) .* R_cont(k,:);%R_disc .* exp(- (t-tspk) ./ tau_Dep )) ;
        
    if ~isempty(indx_active)
        u_disc(indx_active) = u_cont(k,indx_active);
        R_disc(indx_active) = R_cont(k,indx_active);
        I_disc(indx_active) = I_cont(k,indx_active);
        
    end
    
    tspk(indx_active) = t;
    
    indx_0 = find(tspk==0);
    if ~isempty(indx_0)
    u_cont(k,indx_0) = 0;
    R_cont(k,indx_0) = 1;
    I_cont(k,indx_0) = 0;
    u_disc(indx_0) = 0;
    R_disc(indx_0) = 1;
    I_disc(indx_0) = 0;
    end
%    [V_LIF] = LIF_model;
    k = k+1;
    Delta_syn = zeros(1,Trial_num);
    indx_active = [];
end
for i = 1:Trial_num
I_cont_delay(1+Delay(i):L,i) = I_cont(1:L-Delay(i),i);
end
