function locmax = sj_locmax3d(source,leadfield,r)

if nargin == 2
    r = 1;
    warning('Nebylo zad�no rozli�en� SOURCEMODELU - nastaven 1.');
elseif nargin == 1
    error('Nen� zad�na struktura LEADFIELD jako druh� argument funkce');
elseif nargin == 0
    error('Nen� zad�n vektor (P dip�l� x 1) aktivit a struktura LEADFIELD');
end

cube = [-r 0 r -r 0 r -r 0 r -r 0 r -r r -r 0 r -r 0 r -r 0 r -r 0 r;
    -r -r -r -r -r -r -r -r -r 0 0 0 0 0 0 0 0 r r r r r r r r r;
    -r -r -r 0 0 0 r r r -r -r -r 0 0 r r r -r -r -r 0 0 0 r r r];

locmax = zeros(length(source),1);
% reverseStr = '';

parfor d = 1:length(source)
    
%     percentDone = 100 * d / length(source);
%     msg = sprintf('V�po�et lok�ln�ch maxim: %3.1f', percentDone);
%     fprintf([reverseStr, msg]);
%     reverseStr = repmat(sprintf('\b'), 1, length(msg));
    
    if leadfield.inside(d) == 0
        continue
    end
    
    position = leadfield.pos(d,:);
    curr_source = source(d);
    
    
    
    surrounding = position' + cube;
    
    [~,~,surrounding_indx] = intersect(surrounding',leadfield.pos,'rows');
    
    source_surrounding = source(surrounding_indx);
    eval = sum(curr_source < source_surrounding(~isnan(source_surrounding)));
    if eval == 0
        locmax(d) = 1;
    end
    
   
    
end
locmax = logical(locmax);
end

