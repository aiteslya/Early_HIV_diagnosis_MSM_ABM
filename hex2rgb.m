function [rgb_arr]=hex2rgb(hex_str)
% this function takes a hex string of a color code and converts it to rgb
% triplet, normalized 1. 

%check the input
if numel(hex_str)~=6
    myname=mfilename;
    err_str=[myname,': hex string has invalid length'];
    error(err_str);
end

rgb_arr=zeros(1,3);
base=255;

for counter=1:3
    h=hex_str((counter*2-1):(counter*2));
    if double(h(2))>47 & double(h(2))<58 % '0'-'9'
        rgb_arr(1,counter)=rgb_arr(1,counter)+double(h(2))-48;
    elseif double(h(2))>96 & double(h(2))<103 % 'a'-'f'
        rgb_arr(1,counter)=rgb_arr(1,counter)+double(h(2))-87;
    elseif double(h(2))>64 & double(h(2))<71 % 'A'-'F'
        rgb_arr(1,counter)=rgb_arr(1,counter)+double(h(2))-55;
    else
        myname=mfilename;
        err_str=[myname,': hex string is invalid'];
        error(err_str);
    end

    if double(h(1))>47 & double(h(1))<58 % '0'-'9'
        rgb_arr(1,counter)=rgb_arr(1,counter)+16*(double(h(1))-48);
    elseif double(h(1))>96 & double(h(1))<103 % 'a'-'f'
        rgb_arr(1,counter)=rgb_arr(1,counter)+16*(double(h(1))-87);
    elseif double(h(1))>64 & double(h(1))<71 % 'A'-'F'
        rgb_arr(1,counter)=rgb_arr(1,counter)+16*(double(h(1))-55);
    else
        myname=mfilename;
        err_str=[myname,': hex string is invalid'];
        error(err_str);
    end
end

 rgb_arr=rgb_arr/255;
end



