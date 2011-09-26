%maxnet simulation: for nnodes number of nodes, each node has a unity
%autapse and every pair of nodes has mutual inhibition of strength eps (<0)
% start w/ random initialization of the neural outputs, sigma_vec, then
% simulate the evolution of the network (with implicit time constant = 1)
%activiation function is assumed to output zero for any negative input, but
%is linear (with slope=1) for any non-negative input
clear all %delete any old variables still hanging around
figure(1) %clear figure 1 for display
clf %clear the current figure

eps=-0.02; %choose mutual inhibition strength
nnodes = 5; %choose a number of interconnected nodes
W=ones(nnodes,nnodes); %need to populate weight matrix--start w/ all ones
%fix the values of W to be correct, using unity autapses and mutual
%inhibition of strength eps

W %view the result

%initialize a set of outputs:
sigma_vec = rand(nnodes,1)
sigma_history=[sigma_vec];
time =0; %create time vector to enable plotting
time_vec=[time];
%plot evolution of all outputs up to this point...
figure(1)
clf
hold all %allow adding new data to figure 1
for i=1:nnodes
    plot(time,sigma_vec(i))
end

while 1>0   %infinite loop; requires user to hit ctl-C to break out of loop--else revise termination condition
    time=time+1; %implicitly sets the time delay of each neuron (stimulus to response) to be 1 unit
    time_vec=[time_vec,time]; %add an element to the time vector
 
    net_inputs = W*sigma_vec %make sure you understand what this means and why it is true

    %for each neuron, compute firing rate as a function of net voltage at soma
    for i=1:nnodes
        sigma_vec(i)=activation_fnc(net_inputs(i)); %outputs follow from inputs and activation fnc
    end
    sigma_vec %display the output values
    sigma_history=[sigma_history,sigma_vec]; %keep track of this for plotting history
 
    %rest of this is just plotting--overwrite the figure to show current status
    hold off %clear the figure
    clf
    hold all %allows adding multiple lines to the plot
    for i=1:nnodes
        y_vec=sigma_history(i,:); %strip off i'th row of neural responses (for i'th neuron's responses)
        plot(time_vec,y_vec) %plot this neural response vs time
    end
    title('Maxnet time history of outputs')
    xlabel('time')
    ylabel('sigma outputs')
    % done with plot
    pause %for single-stepping; user must hit "enter" to continue with next iteration
end


    
        