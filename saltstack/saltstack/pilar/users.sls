users:
   
     kartacaUser:
       username: Kartaca
       uid: 2023
       home: /home/krt
       gid: 2023
       shell: /bin/bash
       password: {{ kartaca2023 }}
       groups:
         -sudo
         -adm
         -dip
         -plugdev
        user_files:
        enabled: true 
        