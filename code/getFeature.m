function Feature = getFeature(Sig)
% Calculate the 6-D feature descriptor

X = Sig(:, 1);
Y = Sig(:, 2);
T = length(Sig);

dX = Derivation(X);     % dx
dY = Derivation(Y);     % dy
Vel = zeros(size(X));   % velocity
Angle = zeros(size(X)); % angle
for t = 1 : T
    Vel(t) = sqrt(dX(t) * dX(t) + dY(t) * dY(t));
    if dY(t) ~= 0
        Angle(t) = atan(dY(t) / dX(t));
    else
        Angle(t) = 0;
    end
end
dAngle = Derivation(Angle);
dVel = Derivation(Vel);
Logcr = zeros(size(X));
Tam = zeros(size(X));
for t = 1 : T
    Logcr(t) = log((abs(Vel(t)) + 0.01) / ((abs(dAngle(t)) + 0.01)));
    Tam(t) = sqrt(dVel(t) * dVel(t) + Vel(t) * Vel(t) * dAngle(t) * dAngle(t));
end
Feature = [X, Y, Angle, Vel, Tam, Logcr];

% signal normalization
Feature = zscore(Feature);
end

function dsignal = Derivation(signal)
% second-order regression
T = length(signal);
dsignal = zeros(size(signal));
dsignal(1) = (2*signal(3) + signal(2) - 3*signal(1)) / 5;
dsignal(2) = (2*signal(4) + signal(3) - 2*signal(2) - signal(1)) / 6;
for t = 3 : T-2
    dsignal(t) = (2*signal(t+2) + signal(t+1) - signal(t-1) - 2*signal(t-2)) / 10;
end
dsignal(T-1) = (signal(T) - signal(T-2) + 2*signal(T-1) - 2*signal(T-3)) / 6;
dsignal(T) = (3*signal(T) - signal(T-1) - 2*signal(T-2)) / 5;
end