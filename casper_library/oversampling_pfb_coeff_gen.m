function [row] = oversampling_pfb_coeff_gen(W,coeff_width,bus_width,taps,tap)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Outputs the pfb coefficients for each tap. The output includes two     %
    % rows, one row for each of the two ROM blocks. The coeffs must be split %
    % across multiple ROM blocks because Simulink can't specify the initial  %
    % value of memory blocks wider than about 50 bits.                       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	B = bus_width;       % Bus width determines how many coeffs fit in a single row on the ROM
	N = length(W);       % Length of entire coefficients window
	M = N/taps;          % Length of subwindow aka, the FFT length
    row = zeros(2,M/B);  % Initialise output matrix (2 ROMs x Each with M/B rows)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% Data map of coefficient ROM blocks %%%%%%%%%%
    %%%%%%%%%%           X = tap * M           %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% ROM_MSB %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % W(X+M)   % ... % W(X+M-(B/2)+2)   % W(X+M-(B/2)+1)   % <-ram_width = coeff_bits*(B/2)
    %     .    %  .  %         .        %         .        %
    %     .    % ... %         .        %         .        %
    %     .    %  .  %         .        %         .        %
    % W(X+3*B) % ... % W(X+2*B+(B/2)+2) % W(X+2*B+(B/2)+1) %
    % W(X+2*B) % ... % W(X+B+(B/2)+2)   % W(X+B+(B/2)+1)   %
    % W(X+B)   % ... % W(X+(B/2)+2)     % W(X+(B/2)+1)     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%% ROM_LSB %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % W(X+M-(B/2))    %  ...  % W(X+M-B+2)  % W(X+M-B+1)   % <-ram_width = coeff_bits*(B/2)
    %       .         %   .   %      .      %     .        %
    %       .         %  ...  %      .      %     .        %
    %       .         %   .   %      .      %     .        %
    % W(X+3*B-(B/2))  %  ...  % W(X+2*B+2)  % W(X+2*B+1)   %
    % W(X+2*B-(B/2))  %  ...  % W(X+B+2)    % W(X+B+1)     %
    % W(X+B-(B/2))    %  ...  % W(X+2)      % W(X+1)       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
	for r=0:(M/B)-1

		X = 0;
		for i=0:(B/2)-1
            val = round( W( (tap+1)*M - r*B - i )*2^(coeff_width-1) );
            % --- Fix out of range values
            if val < -2^(coeff_width-1)
                val = -2^(coeff_width-1);
            end
            if val > 2^(coeff_width-1)-1
                val = 2^(coeff_width-1)-1;
            end
            % --- Convert Signed to Unigned Representation
            if val >= 0
                VAL = val;
            else
                VAL = 2^(coeff_width) + val;            
            end
            % --- Place VAL into the correct position
            X = X + VAL*2^((B/2)*coeff_width-coeff_width*(i+1));
            
        end
		row(1,r+1) = X;
        
        X = 0;
		for i=(B/2):B-1
            val = round( W( (tap+1)*M - r*B - i )*2^(coeff_width-1) );
            % --- Fix out of range values
            if val < -2^(coeff_width-1)
                val = -2^(coeff_width-1);
            end
            if val > 2^(coeff_width-1)-1
                val = 2^(coeff_width-1)-1;
            end
            % --- Convert Signed to Unigned Representation
            if val >= 0
                VAL = val;
            else
                VAL = 2^(coeff_width) + val;            
            end
            % --- Place VAL into the correct position
            X = X + VAL*2^((B)*coeff_width-coeff_width*(i+1));
        end
		row(2,r+1) = X;
          
    end
    
end