# Add cloudflare gpg key
 mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg |  tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' |  tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
 apt-get update &&  apt-get install cloudflared

# put token after 'install'
 cloudflared service install #DeleteThisCommentedStringAndPasteToken
