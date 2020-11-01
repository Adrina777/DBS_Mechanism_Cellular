function [V] = LIF_Simple(I_Total, R, tau_V, Th, dt) %** LIF_AHP(gE, gI, Idc, Th, dt)

% tau_V = 10; % msec
% R = 1; %Mohm
%dt = 0.05; % msec
EL = -70; % mV
V_th = Th;% -50;
Iin = I_Total;
V = zeros(size(Iin)); 
q = EL;
abs_ref = 1;
k=1;
while k<=length(Iin)-1/dt
    dqdt = 1/tau_V * (-(q-EL) + R*Iin(k));
    q = q + dt*dqdt;
    if q>=V_th 
        V(k) = 50;
        q = -90;
        V(k+1:k+abs_ref/dt) = -90;
        k = k + abs_ref/dt;
    else
        V(k) = q;
        k = k + 1;
    end
    q = V(k-1);
end