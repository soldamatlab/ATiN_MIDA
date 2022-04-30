function [inside] = get_inside(mri, pos2head, posUnit)
mri = ft_convert_units(mri, posUnit);
check_required_field(mri, 'transform');
check_required_field(mri, 'gray');

pos2mri             = ft_warp_apply(inv(mri.transform), pos2head);                  % transform to MRI voxel coordinates
pos2mri             = round(pos2mri);
inside              = getinside(pos2mri, mri.gray);                                     % use helper subfunction
inside = inside(:);
end

function inside = getinside(pos, mask)

% it might be that the box with the points does not completely fit into the
% mask
dim = size(mask);
sel = find(pos(:,1)<1 |  pos(:,1)>dim(1) | ...
  pos(:,2)<1 |  pos(:,2)>dim(2) | ...
  pos(:,3)<1 |  pos(:,3)>dim(3));
if isempty(sel)
  % use the efficient implementation
  inside = mask(sub2ind(dim, pos(:,1), pos(:,2), pos(:,3)));
else
  % only loop over the points that can be dealt with
  inside = false(size(pos,1), 1);
  for i=setdiff(1:size(pos,1), sel(:)')
    inside(i) = mask(pos(i,1), pos(i,2), pos(i,3));
  end
end
end
