IF you want just run test invairment or up web-site without GH Actions (CI/CD):

1) Place Dockerfile in working directory and run command: 

        docker build -t image_name . 

2) Push your image in DockerHub(optional!):

        docker login

        docker push NAME[:TAG]

        docker push DH_Name/iamge_name:latest
3) Run your docker container:

       docker run -d -p 8080:3000 image_name

4) Check if website is avaliable in browser:

       localhost:8080

5) If you see project web-site then you did everything right!

   If not then it's time to investigate what's wrong :)

   Remember right now your website do NOT have encryption.
6) To encrypt website use Caddyfile and Caddy container.
   
