run setup script from proxmox helper scripts https://community-scripts.github.io/ProxmoxVE/scripts?id=wordpress

bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/wordpress.sh)"

follow the prompts, I opt for 2cpu and 4gb ram 

install wp cli 
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp


Go to Cloudflare > Zero Trust > Networks > Tunnels.
Click Create a Tunnel, name it, then hit Create.
Select the Debian tab and copy the left command block under:
"If you don’t have cloudflared installed on your machine:"
Paste that command into your LXC console and run it.
Expected Output:
100 17.6M  100 17.6M    0     0  31.8M      0 --:--:-- --:--:-- --:--:-- 31.8M
Selecting previously unselected package cloudflared.
Unpacking cloudflared (2025.2.1) ...
Setting up cloudflared (2025.2.1) ...
2025-03-20T16:08:25Z INF Using Systemd
2025-03-20T16:08:29Z INF Linux service for cloudflared installed successfully
Back in Cloudflare, at the bottom, check the Connectors section.
It should show "Connected" after a minute or two.

Cloudflare Tunnel Connected

5️⃣ Add Your Website Route
Click Next in Cloudflare.

Add your route:

Subdomain: Enter the subdomain you put in for the site name (e.g., testing).
Domain: Select your domain.
Service Type: HTTP.
URL: Enter the IP address of your LXC.
Click Save, then go to the URL you made (e.g., http://testing.domain.com).
✅ You should see the "Say Hello to Grav!" page or whatever pages you created.


