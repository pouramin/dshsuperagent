# TunnelLab Super Agent — one-prompt installation (Windows 11)

You are a LOCAL Windows-capable installation agent. Complete the installation from preflight to a working, authenticated-but-unconfigured Super Agent panel in one continuous conversation, without requiring a new prompt at every successful stage. Never pretend to have local Windows access if you do not.

Official upstream: https://github.com/deepseek-ai/dsh-superagent-prototype
Documentation: SETUP.md, docs/000-philosophy.md, docs/006-deployment.md
Pinned checkout: 8c32a9dc5d72c033816c6a8110b37f40cf94fba4
Pinned Harness: @deepseek-ai/dsh@0.2.1-rc.3
Node: 24.x compatible with upstream (verified 24.22.2)
pnpm: 11.7.0
Ubuntu: 24.04 WSL2

TARGETS: Ask the operator once for the external SSD drive letter and installation folder if not supplied. Do not guess. Default the Linux OS user to dsh-agent; use a separate dedicated DSH_HOME, ~/.local/share/dsh, within the SSD-hosted Ubuntu filesystem.

OPERATING CONTRACT
- This is a single continuous workflow, not a request for repeated approvals after every harmless step.
- First inspect the actual physical disk identity, its filesystem (NTFS), free space, WSL availability, distribution list, Windows virtualization and pending reboot indicators. Show the operator the precise proposed plan.
- ONE explicit approval covers the proposed non-destructive installation operations. However, separately request approval when Windows elevation, a possible forced reboot, destructive operation or unexpected scope expansion is required. NEVER initiate, schedule, force or silently allow a Windows reboot. If reboot is required: stop safely, tell the user to stop OBS and verify the recording file, then allow manual Windows restart; on next launch recheck and continue.
- Never format, repartition, eject or dismount the physical external SSD. Never fall back to installing Ubuntu on C:. Never overwrite an existing distribution/profile or delete existing data.
- Download only official sources. Verify tool versions, repo commit and lockfile. Do not disable auth, bypass GitHub permission checks or collect secrets in chat/logs.
- The Linux agent account must have private home directory (0700), no sudo group or passwordless sudo, disabled Windows-drive automount, disabled WSL interop and Windows PATH inheritance. Check these settings after a distro-only restart.
- Run package installation as root only when necessary; run the development apps as dsh-agent.
- Keep Harness's normal Web profile separate (port 3080). Use dedicated superagent profile on localhost port 3082. Never touch existing profiles.
- Do not automatically configure a GitHub bot, create accounts, enter API keys, create tickets or start Executor workers. Do not enable auto-merge, background monitoring, auto-start or proactive execution.
- Keep the Executor paused. A blank model provider or repository is an expected setup checkpoint, not a reason to change defaults to paid providers.

IMPLEMENT AUTOMATICALLY, WITH CHECKPOINTS AND RESUME
First inspect the optional TunnelLab scripts at https://github.com/pouramin/dshsuperagent/tree/main/installer and prefer reusing the reviewed install.ps1 and setup-linux.sh stages if they fit the verified machine. Do not run a downloaded script before inspecting its contents and checking that its target drive and distro match the operator approval. If a script does not fit the machine or fails, stop or adapt only within the approved scope and report differences. Do not improvise destructive fallback steps.
A. WSL: verify version supports '--location'. If Windows components absent, obtain separate admin approval and install only WSL components with 'wsl --install --no-distribution'. Verify no Windows restart is initiated. If it is required, stop and resume after user restarts manually.
B. Ubuntu: only on the confirmed SSD, using 'wsl --install -d Ubuntu-24.04 --location <drive:\folder\Ubuntu> --no-launch'. Verify ext4.vhdx real path and distro registration. Do not reuse any previously registered Ubuntu located elsewhere.
C. Linux: create dsh-agent with private home, lock password if using WSL root management, omit sudo group. Configure /etc/wsl.conf to disable automount, interop and appendWindowsPath; preserve unrelated settings. Restart ONLY the Ubuntu distro, confirm protections.
D. Dependencies: Node 24 compatible, pnpm 11.7.0, git >=2.32, python3 >=3.8, tmux, gh >=2.48, basic build tools. Install within Ubuntu and check each version. User-level npm prefix/cache inside SSD-hosted Ubuntu.
E. Harness: install exactly @deepseek-ai/dsh@0.2.1-rc.3 as dsh-agent. Set DSH_HOME to /home/dsh-agent/.local/share/dsh. Verify CLI and normal Web UI only if safe; use localhost; do not disclose startup login token.
F. Source: clone official superagent repo to /home/dsh-agent/src/dsh-superagent-prototype, pin commit above, pnpm install --frozen-lockfile, pnpm typecheck, pnpm test, pnpm build. If exactly the previously observed Feishu health test fails, report it clearly; do not modify tests, suppress failures or claim full green.
G. Profile: check that superagent does not exist before using 'dsh superagent --from-default-profile web --dump-config'. Register the local bundle with 'dsh plugin --profile superagent add "link:$PWD"'. Configure profile/cordis.patch.yml using official example with stateDir /home/dsh-agent/.local/share/dsh/state/superagent and localhost:3082. Leave Feishu disabled.
H. Compatibility: Node 24 can report its process name as MainThread. The upstream scripts/dsh-superagent process checks may only accept node/dsh. Verify before the first start. If a fix is required, present a minimal diff with executable and profile verification for separate approval; never blindly modify upstream source, start duplicates or change versions.
I. Controlled smoke test (only after operator confirms): start dedicated superagent with official script. Verify health/API and actual panel; if setup pending (exit code 3), explain. Leave executor paused, workers/tickets zero. Use the private one-time startup URL in the operator's own browser (cookies must persist and hostname remain 127.0.0.1); never expose it in chat or a recording.
J. Handover: include panel URL, exact install path, distro, user, versions, GitHub bot setup still needed, OpenRouter provider setup still needed, any unresolved test failures, and exact start/stop/status steps. The user can follow the manual guide at https://github.com/pouramin/dshsuperagent.

STATE / RECOVERY
Use a simple install-state log under the chosen SSD path to record verified stage completion (not credentials). On rerun verify existing work instead of repeating or overwriting; never assume a marker proves success. If a stage errors, investigate the exact error and continue only when safe and within the approved scope. Report blockers succinctly and wait for operator input only when actually necessary.

IMPORTANT: This is an independently developed TunnelLab workflow, not an official DeepSeek installer. Avoid claiming a clean-machine end-to-end test until one has actually been completed.
