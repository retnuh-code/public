# 🚀 Grav CMS + Cloudflare Tunnel + Load Balancer Setup Guide

## **1️⃣ Create a Debian LXC Instance**
I recommend using the **Community Scripts** version since it's easy and I'm lazy:  
👉 [Proxmox Community Scripts - Debian LXC](https://community-scripts.github.io/ProxmoxVE/scripts?id=debian)

---

## **2️⃣ Run the Initial Setup Script**
Once your Debian LXC is up and running, execute the following command:

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/retnuh-code/public/main/proxmox/grav+gantry5/initial-setup.sh)"
```

🕐 **This will take a few minutes** as it installs all prerequisites and configurations.  
⏳ If your LXC is not updated, it might take longer.  

✅ **Once completed, it will display your local IP** to configure the site.

---

## **3️⃣ Log into Grav**
1. Open a browser and go to the **URL provided** (e.g., `http://10.1.1.10/admin`).
2. **Create an admin account**.
3. **Test your site** by visiting `http://10.1.1.10/` and confirming it loads properly.
4. If the script **doesn't show the IP**, run:

   ```bash
   ip addr
   ```

   Look for your **LXC's IP address** and use that.

---

## **4️⃣ Set Up a Cloudflare Tunnel**
1. Go to **Cloudflare** > **Zero Trust** > **Networks** > **Tunnels**.
2. Click **Create a Tunnel**, **name it**, then hit **Create**.
3. Select the **Debian** tab and copy the **left command block** under:  
   **"If you don’t have cloudflared installed on your machine:"**  
   Paste that command into your **LXC console** and run it.

### **Expected Output:**
```
100 17.6M  100 17.6M    0     0  31.8M      0 --:--:-- --:--:-- --:--:-- 31.8M
Selecting previously unselected package cloudflared.
Unpacking cloudflared (2025.2.1) ...
Setting up cloudflared (2025.2.1) ...
2025-03-20T16:08:25Z INF Using Systemd
2025-03-20T16:08:29Z INF Linux service for cloudflared installed successfully
```

4. **Back in Cloudflare**, at the bottom, check the **Connectors section**.  
   It should show **"Connected"** after **a minute or two**.

   ![Cloudflare Tunnel Connected](https://github.com/user-attachments/assets/030c340f-4107-46f3-a0a1-23827d94bd0e)

---

## **5️⃣ Add Your Website Route**
1. Click **Next** in Cloudflare.
2. Add your route:
   - **Subdomain:** Enter the subdomain (e.g., `testing`).
   - **Domain:** Select your domain.
   - **Service Type:** HTTP.
   - **URL:** Enter the **IP address of your LXC**.

3. Click **Save**, then go to the **URL you made** (e.g., `http://testing.domain.com`).  
   ✅ You should see the **"Say Hello to Grav!"** page or whatever pages you created.

💡 **Pro Tip:** If you're setting this up in one go, **edit the home page** and add `"SERVER2"` next to `"Say Hello to Grav!"` so you know which server is responding.

---

## **6️⃣ Enable Cloudflare Load Balancing**
### **🛠️ Create the Load Balancer**
1. Go back to the **Cloudflare homepage** (click the Cloudflare logo in the top left).
2. Select the **domain you're working with**.
3. Navigate to **Traffic > Load Balancing**.
4. Click **Enable Load Balancing** (**$5/month** for two endpoints).
5. Click **Create Load Balancer**.
6. Enter the **hostname** for your website:
   - If you want to **test first**, use a test subdomain.
   - If this is for your **main site**, just enter `domain.com` (without leading `.`).

7. Click **Next**.

---

## **7️⃣ Configure the Load Balancer Pools**
### **📌 First Pool (Primary)**
- **Name:** `tunnelname-pool-primary`
- **Steering:** **Random** (default).
- **Endpoints:**
  - **Endpoint Name:** Name it something identifiable (e.g., `PrimaryLXC`).
  - **Endpoint Address:**  
    - Open Cloudflare **Zero Trust > Networks > Tunnels**.
    - Select your tunnel and copy the **TUNNEL ID**.
    - Paste the **TUNNEL ID** and add `.cfargotunnel.com`.
    - Example: `12345abc-12ab-ab34-1234-12cd34ab90ab.cfargotunnel.com`
  - **Weight:** `1`.
  - **Add Host Header:**  
    - **Header value:** Your **subdomain** (e.g., `primary.domain.com`).

- **Remove the extra endpoint**, then **Save**.

### **📌 Second Pool (Secondary)**
- **Name:** `tunnelname-pool-secondary`
- **Steering:** **Random**.
- **Endpoints:**
  - **Endpoint Name:** Something identifiable (e.g., `SecondaryLXC`).
  - **Endpoint Address:** **Same TUNNEL ID** as the primary pool.
  - **Weight:** `1`.
  - **Add Host Header:**  
    - **Header value:** The **secondary subdomain** (`secondary.domain.com`).

- **Remove the extra endpoint**, then **Save**.

---

## **8️⃣ Set Up Health Checks**
1. Click **Next** to go to the **Monitor Page**.
2. Select **Attach Monitor** on either pool.
3. Click **Create a Monitor**, set:
   - **Name:** `PING`
   - **Leave the rest as default**, then click **Save**.
4. Optionally input a **email address** for notifications, otherise hit save
5. Attach the **same monitor** to the **second pool**.

⏳ **Wait 1-2 minutes** for the status to update.  
- **If a pool shows "Critical"**, remove the monitor and re-add it.
- If needed, create a **new monitor** and name it `PING2`.

📌 **Note:** If you **haven't finished the Grav admin setup**, the health checks **will fail**. Go back to your primary.domain.com/admin and create the initial user.

---

## **9️⃣ Finalizing the Load Balancer**
1. **Traffic Steering:**  
   - If you **don't have advanced Cloudflare features**, select **Least Outstanding Requests**.
2. Click **Next** → **Next** to skip over the Custom Rules → **Save and Deploy**.

### **✅ Test the Load Balancer**
1. Open your domain.
2. If you **modified the homepage** on your secondary.domain.com with `"SERVER2"`, refresh the page multiple times to confirm it's switching servers.

📌 **Note:** You may have to refresh a bunch. Dont just spam it, let the page load everytime. 

---

## **🔗 Optional: Add a `www.` Record**
If using this for your **main domain**, you need a `www.` record:
1. Go to **Cloudflare Dashboard > DNS**.
2. Click **Add Record**:
   - **Type:** `CNAME`
   - **Name:** `www`
   - **Target:** `@` (or `yourdomain.com`)
3. Click **Save**.
4. Test by visiting `www.yourdomain.com`.

---

## **🎉 Done! Your Site is Now Load-Balanced with Cloudflare**
Now your **Grav CMS is behind a Cloudflare Tunnel with Load Balancing** for redundancy! 🚀  
If you encounter any issues, **check Cloudflare logs, Nginx logs, and health check statuses**.
