function sid = get_computer_id()
% SID = GET_COMPUTER_ID Returns an ID uniquely identifying the computer.
%
% It uses the MAC address, and is based on code from:
% http://undocumentedmatlab.com/blog/unique-computer-id/
%
% Copyright 2014 Donders Institute, Nijmegen, NL
  
  sid = '00';
  ni = java.net.NetworkInterface.getNetworkInterfaces;
  while ni.hasMoreElements
    addr = ni.nextElement.getHardwareAddress;
    if ~isempty(addr)
      addrStr = dec2hex(int16(addr)+128);
      sid = [sid, '.', reshape(addrStr,1,2*length(addr))];
    end
  end
  
  sid = [sid, '.', computer('arch')];
end
