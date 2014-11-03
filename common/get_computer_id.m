function sid = get_computer_id()
%
% Function that returns a unique computer ID.
% http://undocumentedmatlab.com/blog/unique-computer-id/
%

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
