#!/bin/bash
WORKSPACE_DIR=$(pwd)

echo "=== 1. Setting up system tools ==="
sudo apt-get update && sudo apt-get install -y curl jq zip unzip

echo "=== 2. Creating server directory ==="
mkdir -p server/plugins
cd server

echo "=== 3. Downloading Paper 1.21.1 (Raw Storage CDN) ==="
curl -L -o server.jar "https://fill-data.papermc.io/v1/objects/39bd8c00b9e18de91dcabd3cc3dcfa5328685a53b7187a2f63280c22e2d287b9/paper-1.21.1-133.jar"

echo "=== 4. Setting server configs ==="
echo "eula=true" > eula.txt
printf "online-mode=false\ngamemode=creative\ndifficulty=normal\n" > server.properties

echo "=== 5. Downloading ViaVersion Suite (1.8 - 1.21.1 Support) ==="
curl -L -o plugins/ViaVersion.jar $(curl -s "https://api.modrinth.com/v2/project/viaversion/version" | jq -r '.[0].files[0].url')
curl -L -o plugins/ViaBackwards.jar $(curl -s "https://api.modrinth.com/v2/project/viabackwards/version" | jq -r '.[0].files[0].url')
curl -L -o plugins/ViaRewind.jar $(curl -s "https://api.modrinth.com/v2/project/viarewind/version" | jq -r '.[0].files[0].url')

echo "=== 6. Downloading & Patching EaglerXPaper with Netty HTTP ==="
curl -L -A "Mozilla/5.0" -o plugins/EaglerXPaper.jar "https://github.com/PlanetDogeCodes/EaglerXPaper/releases/download/v1.1.1-S1/EaglerXPaper.jar"
mkdir -p /tmp/netty_patch && cd /tmp/netty_patch
curl -L -o netty.jar "https://repo1.maven.org/maven2/io/netty/netty-codec-http/4.1.97.Final/netty-codec-http-4.1.97.Final.jar"
jar xf netty.jar && rm -rf META-INF
zip -r -u "$WORKSPACE_DIR/server/plugins/EaglerXPaper.jar" io/
cd "$WORKSPACE_DIR/server" && rm -rf /tmp/netty_patch

echo "=== 7. Creating startup script ==="
printf '#!/bin/bash\njava -Xmx3G -jar server.jar nogui\n' > start.sh
chmod +x start.sh

echo "✅ Setup script completed successfully!"
