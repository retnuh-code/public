Create cloudflared tunnel ex name: 123
run initial-setup.sh

bash -c "$(wget -qLO - https://raw.githubusercontent.com/retnuh-code/public/main/proxmox/grav+gantry5/initial-setup.sh)"

Let it run, takes a couple min to run through all the install prerequisties and configurations 
Will come back with your local ip to configure the site. 
log into that url it posts (ex 10.1.1.10/admin) sign up for the admin account 
then goto just the ip without the /admin (ex 10.1.1.10) and confirm the site loads properly 
if it doesn't show the ip then type in 'ip addr' and it should show your IP

if it's all good, then run the setup-cloudflared.sh 

bash -c "$(wget -qLO - https://raw.githubusercontent.com/retnuh-code/public/main/proxmox/grav+gantry5/setup-cloudflared.sh)"

It prompts for your cloudflare tunnel token. this is found in your Zero Trust > Network > Tunnel > select your tunnel or make one > then in the overview tab ( or the next page if you're making a new one) it will have the install commands. 
Select the Debian option at the top, and copy the install command and paste it into notepad or somehting to extract your token 
Should look like this: 

curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && 
sudo dpkg -i cloudflared.deb && 
sudo cloudflared service install REALLY-LONG-STRING-OF-STUFF

That 'REALLY-LONG-STRING-OF-STUFF' is your token. Copy that and paste into your terminal window (may need to right click and paste as plain text depending on what you're using) 

Assign an IP address; doesn't matter what it is as long as you can differientiate the difference between your primary, secondary, and / or test servers. 
I just use the default one because it's simple and isn't the same as any of my other networks. so for this example we'll put in 172.16.1.11/29

When you rerun these on your secondary / test servers just use the next number (ie in my setup I used 172.16.1.12/29 when I ran it on my secondary server) 

Now to test you did it write (hopefully you did) go into your tunnel in cloudflare, goto public hostname tab, click add or create, and fill in the blanks
if you want you can put a subdomain so like testing then domain select the domain you made the tunnel on / are using 
then for the service type = http and url is just the IP address (172.16.1.11) 

then save then goto the url you made (ie in this example it would be testing.domain.com) and should show the test "Say Hello to Grav!" page or whatever pages you made 

when you're doing this and testing your secondary or test server, just click the public hostname you already made, then select edit, then change the URL to the new cf IP you made (ie on my secondary it would be 172.16.1.12) 
pro tip, if you're just setting this up in one fell swoop, edit the home page and just add SERVER2 right after where it says "Say Hello to Grav!" so you know it worked. 

Now for the fun part. Go back to cloudflare homepage (just click the logo in top left)  
select the domain you're working with 
click Traffic > Load Balancing then Enable Load Balancing 
Edit your settings to what you're using (the default settings for 2 endpoints, 60sec checks, etc is $5/mo) 

Select Create Load Balancer
enter your hostname you've been using; it'll rewrite it, then hit next 
Create a pool for each endpoint. don't put both endpoints in 1 pool
Name: I just name mine my tunnel name so: tunnelname-pool-primary and tunnelname-pool-primary
Select which steering you want, RTFM and figure it out, I just leave it as random or least outstanding requests
Now the fun part, your endpoints. Hopefully you wrote down or know your cf ip's you put in. Put the first one you did in the first endpoint address and name it primary in your primary pool, then put your second cf ip in the second pool endpoint address and name it secondary (or name them whatever you want, idc)
select your virtual network from the drop down in order for this to work. you can go rename it or make a different one, in my exp it doesn't matter. It might matter if you're doing this with multiple tunnels and setups on the same domain, I haven't tested that. 
put weight as 1 for both 
fallback pool will just be your secondary, it's fine.
hit Save 

hit Next to goto the monitor page 
Create a new monitor 
Name it something, then hit save to use default ping. add an email if you want.
wait a few sec to make sure it comes back healthy then hit next 

Traffic steering; if you're cheap like me, you're not paying for the extra features so I select least oustanding requests and hit next 

I don't use custom rules so just hit next 

then hit save and deploy 

Now, hopefully you edited your secondary server to add that Sever2 part because that's how you'll test if your stuff is working. 




