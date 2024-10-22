Pulse-OO Results (as of 4/1/2024):

|Component      | Bug Location                                | Status                  | Link / Explanation                                                                                                                    |
|---------------|---------------------------------------------|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
|LibXPM	        | xpmNextString (src/data.c:240)	      |	PR submitted		| https://gitlab.freedesktop.org/xorg/lib/libxpm/-/merge_requests/24	Loop lacks a check != EOF                                       |
|CryptoPP	| AlignedAllocate (allocate.cpp:54)	      |	PR submitted 		| https://github.com/weidai11/cryptopp/pull/1266			No upper bound for malloc calls	                                |
|CryptoPP	| AlignedAllocate (allocate.cpp:92)	      |	PR submitted 		| https://github.com/weidai11/cryptopp/pull/1266		        Mp upper bound for malloc calls                                 |
|OpenSSL	| http_server_get_asn1_req (http_server.c:462)|	Reported (VD/OSSL) 	| The external IO is unbounded and read by the server without upper bound                                                               |
|OpenSSL	| aes_ecb_cipher (e_aes.c:2531)		      |	Reported (VD/OSSL)      | if ctx == NULL then bl == 0 and the for loop will iterate forever (latent)                                                            |
|OpenSSL	| camellia_ecb_cipher (e_camellia.c:246)      |	Reported (VD/OSSL)      | if ctx == NULL then bl == 0 and the for loop will iterate forever (latent)                                                            |
|OpenSSL	| sm4_ecb_cipher (e_sm4.c)		      | Reported (VD/OSSL)      | if ctx == NULL then bl == 0 and the for loop will iterate forever (latent)                                                            |
|LibXML2	| xmlDictGrow (dict.c:650)		      | Issue submitted         | https://gitlab.gnome.org/GNOME/libxml2/-/issues/683   oldentry = dict->table is reset if (++oldentry >= oldend) leading to inf loop   |
|LibXML2	| xmlHashGrow (hash.c:383)		      |	Issue submitted         | https://gitlab.gnome.org/GNOME/libxml2/-/issues/683   oldentry = hash->table is reset if (++oldentry >= oldend) leading to inf loop   |
|LibXML2	| xmlHashScanFull (hash.c:1018)		      |	Issue submitted         | https://gitlab.gnome.org/GNOME/libxml2/-/issues/683   entry = hash->table is reset if (++entry >= end) leading to infinite loop       |
|LibXML2	| xmlHashScanFull3 (hash.c:1098)	      |	Issue submitted         | https://gitlab.gnome.org/GNOME/libxml2/-/issues/683   entry = hash->table is reset if (++entry >= end) leading to infinite loop       |
