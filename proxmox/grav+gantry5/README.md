create a debian lxc, I recommend community scripts version since it's easy and I am lazy: https://community-scripts.github.io/ProxmoxVE/scripts?id=debian 

run initial-setup.sh:
bash -c "$(wget -qLO - https://raw.githubusercontent.com/retnuh-code/public/main/proxmox/grav+gantry5/initial-setup.sh)"

Let it run, takes a couple min to run through all the install prerequisties and configurations 
it'll tkae longer if your lxc isn't up to date
Will come back with your local ip to configure the site. 
log into that url it posts (ex 10.1.1.10/admin) sign up for the admin account 
then goto just the ip without the /admin (ex 10.1.1.10) and confirm the site loads properly 
if it doesn't show the ip then type in 'ip addr' and it should show your IP


Now go into cloud flare > Zero Trust > Networks > Tunnels 
Make a new tunnel, name it, then hit create 
now hit the Debian tab and copy the left command block "If you don’t have cloudflared installed on your machine:" and paste it into the lxc 

output should be similar to: 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 17.6M  100 17.6M    0     0  31.8M      0 --:--:-- --:--:-- --:--:-- 31.8M
Selecting previously unselected package cloudflared.
(Reading database ... 21129 files and directories currently installed.)
Preparing to unpack cloudflared.deb ...
Unpacking cloudflared (2025.2.1) ...
Setting up cloudflared (2025.2.1) ...
Processing triggers for man-db (2.11.2-2) ...
2025-03-20T16:08:25Z INF Using Systemd
2025-03-20T16:08:29Z INF Linux service for cloudflared installed successfully


back in cloudflare at the bottom it'll show connectors and should show connected after a min or two 
![image](https://github.com/user-attachments/assets/030c340f-4107-46f3-a0a1-23827d94bd0e)

hit next in the bottom right
add in your route to your website

Input the subdomain (!! If you are doing this for your main production site, you still need to use 2 seperate sub domains. It'll reflect on your domain.com / www.domain.com site once we do the load balancer)
Domain sleect your domain 
Service Type is HTTP
URL is the ip address of the lxc

then save then goto the url you made (ie in this example it would be testing.domain.com) and should show the test "Say Hello to Grav!" page or whatever pages you made 

pro tip, if you're just setting this up in one fell swoop, edit the home page and just add SERVER2 right after where it says "Say Hello to Grav!" so you know it worked. 

Now for the fun part. Go back to cloudflare homepage (just click the logo in top left)  
select the domain you're working with 
click Traffic > Load Balancing then Enable Load Balancing
Edit your settings to what you're using (the default settings for 2 endpoints, 60sec checks, etc is $5/mo) 

Select Create Load Balancer
enter your hostname for your website. You can edit this so if you want to do a test one then put whatever you want here. -- if this is for your main domain.com site then remove the beginning . and just have your domain.com there. we will deal with www later
hit next
Create a pool for each endpoint. don't put both endpoints in 1 pool
For the first pool:
Name: I just name mine my tunnel name so: tunnelname-pool-primary
Leave steering to random it does not matter since we are only using 1 endpoint per pool

Now the fun part, your endpoints.
endpoint name: doesn't matter put in your lxc name or something identifiable 
Endpoint Address: this is interesting; open cloudflare in a new tab, go into zero trust > networks > tunnels > select your tunnel name so it shows the info in the right side. Copy the TUNNEL ID. paste that ID into your Endpoint address and add .cfargotunnel.com to the end
So all in all your endpoint address should look like this: 12345abc-12ab-ab34-1234-12cd34ab90ab.cfargotunnel.com
Weight 1
click Add Host Header 
Header value is that subdomain you created in the tunnel (so like if you used Primary then it'd be primary.domain.com)
Remove the other endpoint
Save

For the second pool: 
Name: I just name mine my tunnel name so: tunnelname-pool-secondary
Leave steering to random it does not matter since we are only using 1 endpoint per pool

endpoints: 
endpoint name: name it the second lxc name or something identifiable
Endpoint Address: the same endpoint address from the first pool endpoint 12345abc-12ab-ab34-1234-12cd34ab90ab.cfargotunnel.com
Weight 1
click Add Host Header 
Header value is that subdomain you created in the tunnel (so like if you used Secondary for the second one then it'd be secondary.domain.com)
Remove the other endpoint
Save

hit Next to goto the monitor page 
select Attach Monitor on either pool then select Create a Monitor
in the Name put PING leave the rest as default and hit save
Next you can input a notification email address if you'd like, otherwise hit Save again
on your other pool listed, select Attach monitor, then from the drop down select the GET or PING you just made, hit add, then enter an email or just hit save
wait a minute or two (yes 60-120 seconds) to make sure it comes back healthy on both pools then hit next 
If the second pool comes back Critical or jsut doesn't update, you can remove the monitor and then readd it. sometimes cloudflare is too slow with the polling. (I normally just hit Next and it sorts itself out. If it doesn't at the end, go back and edit it and just make a new monitor and name it PING2)
NOTE: if you didn't finish the admin user creation, the healthchecks will fail.

Traffic steering; if you're cheap like me, you're not paying for the extra features so I select least oustanding requests that way it'll bounce between the two servers during testing, and hit next 

I don't use custom rules so just hit next 

then hit save and deploy 

Now, hopefully you edited your secondary server to add that Sever2 part because that's how you'll test if your stuff is working. 

Now goto the domain you entered in the loadbalancer hostname, it should show your website! 

If you are using this for your main domain.com, you have to add a www. record
Under your DNS records, make a new CNAME record. 
Name is www
target is @ (or put in your domain.com, same thing)
hit Save
Test by going to www.domain.com
