% CTYPE_ISDIGIT(c)
%
% Returns true if character c is a digit

function v = ctype_isdigit(c)
  v = (c >= '0') && (c <= '9');
end
