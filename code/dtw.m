function dist = dtw(t, r)
%DTW Dynamic time warping algorithm.
%   dist = DTW(t, r) computes the original dtw distance between t and r, 
%   where t and r are both N-by-M matrices and M is the time step and often
%   different. 
%
%   Notes
%   -------
%   The iteration formula of D in this version is as follows:
%   D(i,j) = d(Ti,Rj) + min([D(i-1,j), D(i-1,j-1), D(i,j-1)])
%
%   Example
%   -------
%   r = rand([10,2]); t = rand([20,2]);
%   dist = dtw(r,t)

% normalize the input size
t = t'; r = r';
[features, N] = size(t);
[~, M] = size(r);

d = zeros(N, M);
for i = 1 : features
    d = bsxfun(@minus, t(i, :)', r(i, :)).^2 + d ;
end
d = sqrt(d);

D = zeros(size(d));
D(1, 1) = d(1, 1);

for n = 2 : N
    D(n, 1) = d(n, 1) + D(n-1, 1);
end
for m = 2 : M
    D(1, m) = d(1, m) + D(1, m-1);
end
for n = 2 : N
    for m = 2 : M
        D(n, m) = d(n, m) + min([D(n-1, m), D(n-1, m-1), D(n, m-1)]);
    end
end
dist = D(N, M);

    
    