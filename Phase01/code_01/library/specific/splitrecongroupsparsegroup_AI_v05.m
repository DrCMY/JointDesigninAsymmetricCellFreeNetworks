function [ X, LamLog, outparms ] = splitrecongroupsparsegroup_AI_v05( Y, Phi, params)
    eps = 1e-4;
    numgroups = params.numgroups; diagflag = params.diagflag; inparms = params.inparms; mu = params.mu; 
    alph = params.alph; bta = params.bta; p = params.p; epp = params.epp; q = params.q; epq = params.epq; 
    outiter = params.outiter; initer = params.initer; exactflag = params.exactflag;
    [ M, L ] = size( Y );
    N = size( Phi, 2 );
    if isempty( inparms )
        W = zeros( N, L );
        Lam = zeros( N, L );
        Lam2 = zeros( M, L );
    else
        W = inparms.W0;
        Lam = inparms.Lam0;
        Lam2 = inparms.Lam20;
    end
    if diagflag
        figure(400),
        figure(500),
    end
    A = mu * ( Phi' * Phi ) + eye( N );                       
    % main loop
    LamLog = zeros(1,outiter);
    for ii = 1 : outiter
        for jj = 1: initer
            Wold = W;
            % solve for X
            rhs = W - Lam + mu * Phi' * ( Y + Lam2 );
            X = A \ rhs;
            if diagflag
                set( 0, 'CurrentFigure', 400 )
                imagesc( X ), drawnow,
                set( 0, 'CurrentFigure', 500 )
                plot( X( :, 1 ), 'o' ), drawnow,
            end
            %fprintf( 'out = %3d, in = %3d, ||X||_p^p = %6.4g\n', ii, jj, sum( abs(X(:)).^p ) ) % Uncomment for logging out
           
            % update w
            W = groupsparsegroupshrink( X + Lam, alph, bta, p, epp, q, epq, numgroups );
            if mean(abs(Wold-W),'all') < eps
                break
            end
        end
        % update Lagrange multipler, using "method of multipliers"
        Lam = Lam + X - W;
        LamLog (ii) = mean(abs(Lam),"all");
    %     figure, plot(LamLog) % Be careful to turn this on.    
        if exactflag
            Lam2 = Lam2 + ( Y - Phi * X );
            if mean(abs(Lam),'all') < eps && mean(abs(Lam2),'all') < eps
                break
            end
        else
            if mean(abs(Lam),'all') < eps
                break
            end
        end
    end
    % store final values of variables
    outparms.W0 = W;
    outparms.Lam0 = Lam;
    outparms.Lam20 = Lam2;
return

function y = groupsparsegroupshrink( x, alph, bta, p, epp, q, epq, numgroups )
    y = shrink1( x, alph, p, epp );
    y = groupshrink( y, bta, q, epq, numgroups );
return

function y = shrink1( x, lambda, p, ep )
    lambda = lambda^(2-p);                                              
    % p-shrinkage using mollification: https://en.wikipedia.org/wiki/Mollifier
    s = abs( x );
    ss = max( s - lambda * ( s.^2 + ep ).^( p / 2 - 0.5 ), 0 );% ./ t;
    y = ss .* sign( x );         
return

function u = groupshrink( x, lambda, p, ep, numgroups )
    lambda = lambda^(2-p);                                              
    [ m, n ] = size( x );
    groupsize = round( double( m ) / numgroups );
    x = reshape( x, [ groupsize, numgroups * n ] );
    y = vecnorm(x);
    s = max( y - lambda * ( y.^2 + ep ).^( p / 2 - 0.5 ), 0 );
    y( y==0 ) = 1;                                                      % To avoid zero division
    u = repmat( s ./ y, groupsize, 1 ) .* x;
    u = reshape( u, m, n );
return