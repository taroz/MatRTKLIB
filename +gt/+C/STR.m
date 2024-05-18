classdef STR < double
    enumeration
        STR_NONE    (0)  % stream type: none
        STR_SERIAL  (1)  % stream type: serial
        STR_FILE    (2)  % stream type: file
        STR_TCPSVR  (3)  % stream type: TCP server
        STR_TCPCLI  (4)  % stream type: TCP client
        STR_NTRIPSVR(5)  % stream type: NTRIP server
        STR_NTRIPCLI(6)  % stream type: NTRIP client
        STR_FTP     (7)  % stream type: ftp
        STR_HTTP    (8)  % stream type: http
        STR_NTRIPCAS(9)  % stream type: NTRIP caster
        STR_UDPSVR  (10) % stream type: UDP server
        STR_UDPCLI  (11) % stream type: UDP server
        STR_MEMBUF  (12) % stream type: memory buffer
    end
end