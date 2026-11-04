#!/usr/bin/env bash
# Run --system as Ubuntu root, then --app as dsh-agent.
set -Eeuo pipefail
who=dsh-agent
home=/home/dsh-agent
dsh_home="$home/.local/share/dsh"
repo="$home/src/dsh-superagent-prototype"
node_version=24.22.2
gh_version=2.103.3
upstream=8c32a9dc5d72c033816c6a8110b37f40cf94fba4
fail(){ echo "STOP: $*" >&2; exit 2; }
[[ $# == 1 ]] || fail 'Usage: setup-linux.sh --system|--app'
case "$1" in
--system)
 [[ "$(id -u)" == 0 ]] || fail 'root required'
 . /etc/os-release
 [[ "$ID" == ubuntu && "$VERSION_ID" == 24.04 ]] || fail 'Ubuntu 24.04 required'
 export DEBIAN_FRONTEND=noninteractive
 apt-get update
 apt-get install -y ca-certificates curl xz-utils tar git python3 tmux build-essential pkg-config jq
 if ! id "$who" >/dev/null 2>&1; then useradd -m -s /bin/bash "$who"; passwd -l "$who"; fi
 if id -nG "$who" | grep -qw sudo; then fail 'Unexpected sudo group membership'; fi
 chmod 700 "$home"
 python3 - <<'PY'
import configparser
from pathlib import Path
p=Path('/etc/wsl.conf')
c=configparser.ConfigParser(interpolation=None)
c.optionxform=str
if p.exists(): c.read(p)
for s in ('automount','interop','user'):
    if not c.has_section(s): c.add_section(s)
for s,k,v in (('automount','enabled','false'),('interop','enabled','false'),('interop','appendWindowsPath','false'),('user','default','dsh-agent')):
    c.set(s,k,v)
with p.open('w') as f: c.write(f)
PY
 echo 'Linux system setup completed. Restart only the Ubuntu distribution.'
 ;;
--app)
 [[ "$(id -un)" == "$who" ]] || fail 'must run as dsh-agent'
 if mount | grep -Eq ' on /mnt/[a-z] '; then fail 'Windows drives still mounted'; fi
 mkdir -p "$home/.local/bin" "$home/.cache/npm" "$home/src" "$dsh_home"
 chmod 700 "$home" "$dsh_home"
 [[ "$(uname -m)" == x86_64 ]] || fail 'x86_64 required'
 node_dir="$home/.local/node-v$node_version"
 if [[ ! -x "$node_dir/bin/node" ]]; then
   tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
   curl -fLsS --retry 3 "https://nodejs.org/dist/v$node_version/node-v$node_version-linux-x64.tar.xz" -o "$tmp/node.tar.xz"
   curl -fLsS --retry 3 "https://nodejs.org/dist/v$node_version/SHASUMS256.txt" -o "$tmp/SHASUMS256.txt"
   (cd "$tmp"; grep " node-v$node_version-linux-x64.tar.xz$" SHASUMS256.txt | sed "s/node-v$node_version-linux-x64.tar.xz/node.tar.xz/" | sha256sum -c -)
   mkdir -p "$node_dir"
   tar -xJf "$tmp/node.tar.xz" --strip-components=1 -C "$node_dir"
   rm -rf "$tmp"; trap - EXIT
 fi
 export PATH="$node_dir/bin:$home/.local/bin:$PATH"
 npm config set prefix "$home/.local"
 if ! command -v pnpm >/dev/null || [[ "$(pnpm -v)" != 11.7.0 ]]; then npm install -g pnpm@11.7.0; fi
 if ! command -v dsh >/dev/null || [[ "$(dsh --version)" != *0.2.1-rc.3* ]]; then npm install -g @deepseek-ai/dsh@0.2.1-rc.3; fi
 gh_dir="$home/.local/gh-$gh_version"
 if [[ ! -x "$gh_dir/bin/gh" ]]; then
   tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
   curl -fLsS --retry 3 "https://github.com/cli/cli/releases/download/v$gh_version/gh_"$gh_version"_linux_amd64.tar.gz" -o "$tmp/gh.tgz"
   mkdir -p "$gh_dir"
   tar -xzf "$tmp/gh.tgz" --strip-components=1 -C "$gh_dir"
   rm -rf "$tmp"; trap - EXIT
 fi
 ln -sfn "$gh_dir/bin/gh" "$home/.local/bin/gh"
 if [[ ! -d "$repo/.git" ]]; then
   [[ ! -e "$repo" ]] || fail 'Source directory exists but is not a Git checkout'
   git clone https://github.com/deepseek-ai/dsh-superagent-prototype.git "$repo"
 fi
 cd "$repo"
 [[ -z "$(git status --porcelain)" ]] || fail 'Source contains local changes; refusing overwrite'
 git fetch origin "$upstream"
 git checkout --detach "$upstream"
 pnpm install --frozen-lockfile
 pnpm typecheck
 pnpm build
 export DSH_HOME="$dsh_home"
 if [[ ! -d "$DSH_HOME/profiles/superagent" ]]; then
   dsh superagent --from-default-profile web --dump-config >/dev/null
   dsh plugin --profile superagent add "link:$repo"
   sed "s|<absolute path, for example /home/me/.dsh/state/superagent>|$DSH_HOME/state/superagent|g" "$repo/examples/profile.cordis.patch.yml" > "$DSH_HOME/profiles/superagent/cordis.patch.yml"
   mkdir -p "$DSH_HOME/state/superagent"
   chmod 700 "$DSH_HOME/state/superagent"
 else
   echo 'Existing Super Agent profile preserved; no overwrite.'
 fi
 echo 'Verified tools:'
 node -v; pnpm -v; dsh --version; git --version; tmux -V; python3 --version
 "$home/.local/bin/gh" --version | head -1
 echo 'Profile inactive. No secrets, provider, GitHub authorization, workers or services configured.'
 ;;
*) fail 'Usage: setup-linux.sh --system|--app';;
esac
