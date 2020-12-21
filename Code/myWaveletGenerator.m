function [HiD, LoD] = myWaveletGenerator(theta)
% This function generates a orthonormal wavelet, either recursively
% (method_num=1) or analytically given a vector of angles (theta). 
% The decomposition low and high pass are returned.
    method_num = 1;

% ~~~~~~~~~~~~~~~~~~ Recursive construction ~~~~~~~~~~~~~~~~~~
% Generate orthonormal wavelets using Sherlock-Monro Algorithm
% Inputs are a set of angles used in the rotation matrices that 
% define the orthonormal wavelet. 
    if method_num == 1
        % order of filter
        k = length(theta);
        % preallocate space for filter
        H0 = zeros(1,2*k);
        % boundary conditions
        lo = k;
        hi = k+1;
        H0(lo) = cos(theta(1));
        H0(hi) = sin(theta(1));
        % recursion from paper
        for order = 1:k-1
            c = cos(theta(order+1));
            s = sin(theta(order+1));

            H0(lo-1) = c*H0(lo);
            H0(lo) = s*H0(lo);
            H0(hi+1) = c*H0(hi);
            H0(hi) = -s*H0(hi);

            splits = order-1;
            splitbase = lo+1;
            for butterfly = 1 : splits
                hlo = H0(splitbase);
                hhi = H0(splitbase+1);
                H0(splitbase)  = c*hhi - s*hlo;
                H0(splitbase+1)= s*hhi + c*hlo;
                splitbase = splitbase + 2;
            end
            lo = lo - 1;
            hi = hi + 1;
        end

        H1 = flip(H0);
        H1(2:2:end)=-H1(2:2:end);

        LoD = H0;
        HiD = H1;
    end

% ~~~~~~~~~~~~~~~~~~ Analytical construction ~~~~~~~~~~~~~~~~~~
% Generates orthonormal wavelets, analytically
% Only produces wavelets of length 4,6 and 8.
    if method_num == 2
        len = length(T);

        [c0,s0,c1,s1] = deal( cos(T(1)),sin(T(1)), ...
                              cos(T(2)),sin(T(2)) );

        if len == 2
            h0 = [c0*c1, s0*c1, s0*s1, -c0*s1];
            h1 = flip(h0);
            h1(2:2:end)=-h1(2:2:end);

        elseif len == 3
            [c2,s2] = deal( cos(T(3)),sin(T(3)) );

            h0 = [c0*c1*c2, s0*c1*c2, c0*s1*s2+s0*s1*c2,...
                  s0*s1*s2-c0*s1*s2, -s0*c1*s2, c0*c1*s2];
            h1 = flip(h0);
            h1(2:2:end)=-h1(2:2:end);

        elseif len == 4
            [c2,s2,c3,s3] = deal( cos(T(3)),sin(T(3)), ...
                                  cos(T(4)),sin(T(4)) );

            h0 = [c0*c1*c2*c3, s0*c1*c2*c3, ...
                  c0*c1*s2*s3+c0*s1*s2*c3+s0*s1*c2*c3, ...
                  s0*c1*s2*s3+s0*s1*s2*c3-c0*s1*c2*c3, ...
                 -c0*s1*c2*s3+s0*s1*s2*s3-s0*c1*s2*s3, ...
                 -s0*s1*c2*c3-c0*s1*s2*s3+c0*c1*s2*s3, ...
                  s0*c1*c2*s3, -c0*c1*c2*s3];
            h1 = flip(h0);
            h1(2:2:end)=-h1(2:2:end);
        end
        HiD = h0;
        LoD = h1;
    end

    
end
