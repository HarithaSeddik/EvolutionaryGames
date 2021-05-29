clear;clc; close all

N = 20;
A = zeros(N,N); %Matrix for events
B = {}; %Matrix for probabilities

generations = N*N; %Number of generations(iterations)
time = 2000*generations;
tic
%Initialize big A matrix, and B the probability array
for i = 1: size(A)
    for j = 1:size(A,2)
        %Number of Red (1) ,Blue (2) ,Yellow (3),Black (4)
         A(i,j)= randi(4);  %Values 1 to 4
         B{i,j} = rand(1,5); %Vector of probabilities
    end
end

A;

% x0 = [length(find(A==1)) length(find(A==2)) length(find(A==3)) length(find(A==4))]; 

t = 0;
while t < time
    
    cell_index = [randi(N),randi(N)];
    cell = A(cell_index(1),cell_index(2)); %Pick a random cell
    
    local = pbc(cell_index,N);
    neighbors_index= [ cell_index + local ];
    
    neighbors = [A(neighbors_index(1,1),neighbors_index(1,2))
                 A(neighbors_index(2,1),neighbors_index(2,2))
                 A(neighbors_index(3,1),neighbors_index(3,2))
                 A(neighbors_index(4,1),neighbors_index(4,2))];
    
    random = randi(4);   %Random number between 1-4   
    neighbor = neighbors(random); %select neighbor randomly
    neighbor_index = neighbors_index(random,:);
     
    %Update the A matrix, after random cell interacts with random neighbor
   A = interact( A ,B ,cell, cell_index ,neighbor, neighbor_index,t);
   
   t = t +1; %Progress in time

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    img = zeros(size(A,1),size(A,2),3);
    if (mod(t,floor(time/50))==0) %Only plot once every 50 cycles
        for i = 1:size(A,1)
            for j = 1:size(A,2)
                if (A(i,j) == 1) %Red
                    img(i,j,:) = [255 0 0];
                elseif (A(i,j) == 2) %Blue
                    img(i,j,:) = [0 0 255];
                elseif (A(i,j) == 3)%Yellow
                    img(i,j,:) = [255 255 0];
                else %Black
                    img(i,j,:) = [0 0 0];
                end                
            end
        end
        
        image(img)
        drawnow
        
    end
end
toc
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%  FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Function where cell interaction happens
function [A] = interact( A ,B ,cell, cell_index ,neighbor, neighbor_index,t)

    i = cell_index(1); j=cell_index(2);
    m = neighbor_index(1); k=neighbor_index(2);
    
    
    [M , prob] = max(B{i,j}); %1 select %2 reproduction %3 mobility
    
    
    %Promoting the selected interaction (1-selection 2-reproduction 3-mobility)
    if (mod(t,5)==0)   %Change rate accoridng to the mod
        prob = 3;
    end
    
%     neighbor = neighbors(randi(4)); %select neighbor randomly
    if neighbor ~= 4
        switch prob
            case 1
                neighbor = 4; %Kill the neighbor
            case 3
                [cell,neighbor]= deal(neighbor,cell); %swap positions
        end
    else %If selected neighbor is a dead cell
        switch prob
            case 2
                neighbor = cell;
            case 3
                [cell,neighbor]= deal(neighbor,cell); %swap positions
        end
    end
    
%     A_old = A;
    A(i,j) = cell;
    A(m,k) = neighbor;
    B{i,j} = rand(1,3);
    
%     sum(sum(A)) == sum(sum(A_old))
    end
    
%Periodic Boundary Condition
function local = pbc(cell_index,N)

    i = cell_index(1); j=cell_index(2);
    local =[];
    
    if (i==1 && j==1) %Top left Corner
        local= [ 0 N-1; 0 1; N-1 0; 1 0];
    elseif (i==1 && j==N) %Top right Corner
        local= [ 0 -1; 0 -N+1; N-1 0; 1 0];
    elseif (i==N && j==1) %Bottom left corner
        local= [ 0 N-1; 0 1; -1 0; -N+1 0];
    elseif (i==N && j==N) %Bottom right corner
        local= [ 0 -1; 0 -N+1; -1 0; -N+1 0];
    elseif (j==1)%Left Edge
        local= [ 0 N-1; 0 1; -1 0; 1 0];
    elseif (j==N)%Right Edge
        local= [ 0 -1; 0 -N+1; -1 0; 1 0];
    elseif (i==1)%Top Edge
        local= [ 0 -1; 0 1; N-1 0; 1 0];
    elseif (i==N)%Bottom Edge
        local= [ 0 -1; 0 1; -1 0; -N+1 0];
    else
        local= [ 0 -1; 0 1; -1 0; 1 0];
    end
    return 

end