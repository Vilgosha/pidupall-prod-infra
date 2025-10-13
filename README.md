# IF you want just run test invairment or up web-site without GH Actions (CI/CD):

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

   I would recommend run Caddy container separately if you planning encrypt another websites, services etc.

   Ready to go docker-compose for website + encryption:

        version: "3.9"

        services:
          caddy:
            image: caddy:2
            restart: unless-stopped
            ports:
              - "80:80"
              - "443:443"

            volumes:
              - ./Caddyfile:/etc/caddy/Caddyfile:ro # config
              - caddy_data:/data # certs + ACME account
              - caddy_config:/config # admin/config state
            depends_on:
              - app

          app:
            image: image_name
            restart: unless-stopped
            environment:
              - NODE_ENV=production
            expose:
              - "3000"

        volumes:
          caddy_data:
          caddy_config:

   Caddyfile:

        {
                email example@gmail.com
        }

        # Redirect www 
        www.yourdomain.com {
                redir https://yourdomain.com{uri} permanent
        }

        # Primary site
        yourdomain.com {
                encode zstd gzip

                header {
                        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
                        X-Content-Type-Options "nosniff"
                        X-Frame-Options "DENY"
                        Referrer-Policy "no-referrer-when-downgrade"
                }

                # Reverse proxy to the app service in Docker
                reverse_proxy app:3000 

                @health path /healthz
                handle @health {
                        respond "ok" 200
                }
        }

# If you want run pidupall project with encryption and CI/CD pipeline:

1) Create deploy user on server and add him into docker group.

        sudo adduser deploy
        sudo usermod -aG docker deploy
   User should be also placed in GitHub Repository Secrets as DEPLOY_USER
  
3) Allow connection only via SSH keys (PubkeyAuthentication).

        /etc/ssh/sshd_config
 
4) Generate SSH keys.

        ssh-keygen
   Publick key must be placed in /home/deploy/.ssh/authorized_keys.
   
   Private key shoud be place in GitHub Pepository Secrets as DEPLOY_KEY.

5) In target GitHub repository you should have:
   
   DEPLOY_HOST - your server public ip address

   DEPLOY_KEY - your SSH private key

   DEPLOY_PORT - add if you have custom port for deployment if not then set 22 

   DEPLOY_USER - your user created for deployment

   GHCR_TOKEN - generated automatically by deploy.yml in GH actions

   GHCR_USER - in this case it's your GitHub User

6) Add repository variables:
   
   DEPLOY_PATH - /home/deploy/pidupall (example)

   IMAGE_NAME - ghcr.io/vilgosha/pidupall (example)

8) Add Dockerfile, .dockerignore, docker-compose.yml in repository main branch.

9) Also start container with Caddy for encryption. (If already exist then add attached Caddyfile config into Caddyfile on server.)


10) Now then almost everything ready we can try to start our GH actions.

   Go into target repository -> Actions -> New workflow -> set up a workflow yourself and add there configuration from deploy.yml file.

11) Now you can see running CI/CD pipeline.


## If any question feel free to ask. 

