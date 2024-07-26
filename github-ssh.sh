#! /bin/bash
set -e	

#purpose of file is to facilitate setting up github connection via SSH from 
#google cloud virtuam machine instance terminal. 

#see also vm-instance-GCE-protocol.rtf

cd ~/.ssh/
touch id_ed25519
cat > id_ed25519 << EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAACmFlczI1Ni1jYmMAAAAGYmNyeXB0AAAAGAAAABBAdLhLJs
2rCsGd0ppgzGYVAAAAEAAAAAEAAAAzAAAAC3NzaC1lZDI1NTE5AAAAIFCoJeKDEqOsTctW
VH/DZahEckIYY8a6g33o7xUzxNhyAAAAoB+8jpBKrY4Rhp0M78u9wBvHyGYDITt/FO2IYd
KQdft8/gxl5yCQ/H60hkHjWAK94iwqSvtmyR4o+z9D31fAYnpqqaAef7yfz4XYYjcur+8e
2vvI8veW/91E9SoqdeT1QWqachnBl09GnHvC63fwJXPBiOMioMZOAfWgUv3DqeA6c0p5O6
0XpMhF/Pcyqyr/aHCRPx+NKgXm8tEt4v1uD8k=
-----END OPENSSH PRIVATE KEY-----
EOF
touch id_ed25519.pub
cat > id_ed25519.pub << EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCoJeKDEqOsTctWVH/DZahEckIYY8a6g33o7xUzxNhy rcallen1@asu.edu
EOF
chmod 644 id_ed25519.pub
chmod 600 id_ed25519



#to check whether settings are correct, 
# ls -l for permissions, less id_ed25519.pub for file content

