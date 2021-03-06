%hopfield net for Travelling Salesman's Problem
clear all
load 'intercity_distances.dat'; %read in the intercity distances
[n_cities,~] = size(intercity_distances);

n_runs = 20;
V_vec = zeros(n_runs,1);
cost_vec = zeros(n_runs,1);
time_vec = zeros(n_runs,1);
run_count = 1;
while(run_count<=n_runs)
    
    %%%%%%%%%%%%%
    
    %BEGIN TUNING PARAMETERS
    
    %Optimization Parameters (pg 147 of "Neural Computation of
    % Decisions in Optimization Problems") Suppress by setting to 0.
    A = 10;
    B = 10;
    C = 1;
    D = 50000;
    
    %Hopfield recommended Jbias (current) > C*Ncities.
    %Scale up by this factor (default 1.0)
    Jbias_factor = 20.0;
    
    %Influence of integral error term (forces legal solution)
    lambda = 20000.0;
    
    %Integration time step
    dt = 0.0001;
    
    %Input noise scaling
    noise_scale = 0.1;
    %END TUNING PARAMETERS
    
    %Initialize weights
    [W,Tabc] = assign_weights(A,B,C,D,n_cities,intercity_distances);
    
    %Initialize bias currents
    Jbias = C * n_cities;
    J = ones(n_cities,n_cities) * Jbias * Jbias_factor;
    
    %Initialize input U so sum of output V is n_cities; U0=invlogsig(1/ncities)
    %U and V are matrix of neurons: row index==> city, column index==> day
    u0 = -log(-1+n_cities);
    U = ones(n_cities,n_cities)*u0;
    dU = (rand(10,10)-0.5)*2; %Input noise, -1 to 1
    U = U + dU*noise_scale; %Add scaled input noise
    U(1,:) = -10.0; %suppress change for city 1, all days
    U(:,1) = -10.0; %suppress change for day 1, all cities
    U(1,1) = 10; %coerce initialization for city 1 on day 1
    
    %Test that V=~n_cities
    V = logsig(U);  %corresponding Vs; use 0 to 1 sigmoid squashing fnc
    V_sum = sum(sum(V)) %These two lines add up the outputs of all neurons;
    
    %Initialize variables
    int_Eabc=zeros(n_cities,n_cities); %optional for integral-error feedback
    Udot = ones(10,10); %initialization
    niter = 100;
    count = 0;
    
    %Run simulation
    while niter>0
        for i=1:niter
            [Udot,int_Eabc] = compute_udot(V,W,U,J,dt,lambda,int_Eabc,Tabc,Jbias);
            U = U + Udot*dt; %Euler 1-step numerical integration of differential equations
            V = logsig(U); %activation functions
        end
        figure(1)
        bar3(V);
        title('neural outputs')
        figure(2)
        bar3(Udot)
        title('Udot')
        figure(3)
        bar3(int_Eabc)
        title('Integral error terms')
        
        V_sum = sum(sum(V)) %print out how many cities got visited--should converge to 10
        tripcost = compute_trip_cost(V,intercity_distances) %print out cost of the trip
        
        %niter = input('enter number of iterations (<=0 to quit)')
        if(tripcost>0)
            niter=0;
        end
        count = count + 1;
    end
    V_vec(run_count) = V_sum;
    cost_vec(run_count) = tripcost;
    time_vec(run_count) = count;
    run_count = run_count+1;
end

