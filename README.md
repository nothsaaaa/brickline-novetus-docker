# NovetusDocker

A Docker-based solution for deploying low-privilege, headless Novetus servers quickly and easily.

This version includes support for Brickline, allowing you to list your servers publicly for free.

Forked from [Mollomm1/NovetusDocker](https://github.com/Mollomm1/NovetusDocker)

---

## 🚧 Build Instructions

1. **Download Novetus**
   Grab the latest *snapshot version* of Novetus from the official itch.io page.

2. **Setup the Project**
   Extract the downloaded Novetus files into the `Launcher` directory.

3. **Clean the Launcher (optional, but recommended)**
   Remove unnecessary files by running the cleanup script:

   ```bash
   ./clean_client.sh
   ```

4. **Build the Docker Image**
   Use Docker Buildx to create the image:

   ```bash
   docker build -t novetus .
   ```

---

## ▶️ Run Instructions

Start a Novetus server using Docker:

```bash
docker run -d \
  --name=novetus \
  --restart always \
  -p 53640:53640/udp \
  -e CLIENT=2012M `# Optional: Select the client version (default: 2012M)` \
  -e MAXPLAYERS=12 `# Optional: Set maximum number of players` \
  -e PORT=53640 `# Optional: Change the UDP server port` \
  -e MAP="Z:\\default.rbxl" `# Optional: Set the map path inside the container` \
  -e SERVER_NAME="My Brickline Server" `# Optional: Custom server name (masterScript)` \
  -e BRICKLINE_IP="127.0.0.1" `\
  -e BRICKLINE_PORT=5000 `\
  -v ./mymap.rbxl:/default.rbxl `# Optional: Mount a custom map` \
  novetus
```

**Environment Variable Descriptions:**

* `CLIENT`: Specifies the Novetus client version.
* `MAXPLAYERS`: Limits the number of concurrent players.
* `PORT`: Sets the UDP port the Novetus server will use.
* `MAP`: Path to the map inside the container (usually `Z:\\default.rbxl`).
* `SERVER_NAME`: Custom server name used by `masterScript`.
* `BRICKLINE_IP`: Custom IP used by `masterScript`.
* `BRICKLINE_PORT`: Custom port used by `masterScript`.
* `-v ./mymap.rbxl:/default.rbxl`: Mounts a local map file into the container.

---

## ✅ Supported Client Versions

| Version Code | Description |
| ------------ | ----------- |
| 2012M        | **Default** |
| 2011M        | Supported   |
| 2011E        | Supported   |
| 2010L        | Supported   |
| 2009L        | Supported   |
| 2009E        | Supported   |
| 2008M        | Supported   |

**Note:** Versions not listed above are currently unsupported.

---