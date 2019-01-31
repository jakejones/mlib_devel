function [ d ] = oversampling_pfb_coeff_divisor( W , N )
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % To prevent the data from saturating as it propagates  %
    % through the pfb, the binary point of the coefficients %
    % are shifted according to the divisor calculated here. %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % N is the number of channels
    % W is the string of the MATLAB function that generates the coeffs

    [w] = eval(W);
    m = reshape(w,[N length(w)/N]);
    c = max( sum( abs(m) , 2) );
    d = ceil( log(c)/log(2) );   
    d = 2^d;

end