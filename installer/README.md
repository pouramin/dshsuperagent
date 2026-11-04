# TunnelLab Super Agent Installer — Preview

Independent community installation kit for **Windows 11 + external NTFS SSD + Ubuntu 24.04 WSL2**. Not an official DeepSeek installer.

## Files

- [CODEX_PROMPT.md](CODEX_PROMPT.md): the **single prompt** to paste into a local Windows-capable Codex agent. Drives inspection, approvals, dependencies, Harness, build, profile, first smoke test, and handover in one conversation.
- [install.ps1](install.ps1): an interactive PowerShell bootstrap that validates the selected SSD and WSL location, provisions Ubuntu only at the selected path, invokes the Linux setup script, and never reboots Windows.
- [setup-linux.sh](setup-linux.sh): an Ubuntu system preparation stage (privileged) and an application build/profile stage (unprivileged).

## Recommended: one prompt

Open the [installation guide](../index.html), choose **With Codex**, select the correct external drive letter and install folder, then copy the prompt into Codex Desktop running with real access to your Windows machine.

The agent must read the complete CODEX_PROMPT.md. This is a single continuing workflow; it still asks before admin-level changes, Windows reboot, or other elevated-risk actions. The user must authorize Windows UAC and enter account secrets privately.

## Manual PowerShell bootstrap

1. Download or clone this repository. Review both scripts yourself.
2. If WSL is not installed, run the following from an elevated PowerShell window, **only with your own approval**:

    wsl --install --no-distribution

   If Windows requires reboot, stop OBS and save the recording, then restart Windows **manually** and resume.
3. Run from the repository root in PowerShell, with the actual external SSD letter and a clean folder:

    powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1 -DriveLetter D -Folder dsh-superagent

4. Follow the approvals. The script deliberately stops for an unexpected distribution, conflicting location, missing script, insufficient space, or installation failure rather than falling back to C: or overwriting existing data.
5. When complete, the Super Agent profile is **inactive** and does not yet have model or repository access. Continue manual setup below.

## Manual setup after the bootstrap

1. Create a disposable test repository, initialize its README/main commit, and invite a separate **GitHub user account** for the agent. Do not use your personal account as the agent.
2. Use the official [Accounts instructions](https://github.com/deepseek-ai/dsh-superagent-prototype/blob/main/docs/006-deployment.md#accounts) to create a credential-isolated gh-agent wrapper and log in **privately** as the bot account. Verify push permission on only the test repository.
3. Configure an OpenAI Chat Completions-compatible model provider in Harness (e.g. OpenRouter's API base at https://openrouter.ai/api/v1 and model id openrouter/free), then actually test tool calling. The free router may select different models and does not guarantee compatibility.
4. Open the dedicated Super Agent interface after safely starting only that profile (official scripts/dsh-superagent start). A setup-pending status is normal until required account and policy fields are complete. Use the private full startup URL to establish a session cookie; then remain on the same localhost hostname and port.
5. In Settings → Sources set repository and the gh-agent executable; in Policy allow only your own operator login; in Eval and Execution select the working provider/model and enforce review-only delivery. Save the Prepare command using a separately cloned test repository and official worktree example. Start with one worker maximum. Keep Executor paused until you intend to test it.
6. Review and manually merge (or reject) every pull request. Do not auto-merge.

## Scope and safety

- Scripts target **Ubuntu 24.04, x86_64**, Node.js **24.22.2**, pnpm **11.7.0**, Harness **0.2.1-rc.3**, and upstream Super Agent commit **8c32a9dc5d72c033816c6a8110b37f40cf94fba4**.
- External SSD target must be NTFS and have at least 20 GiB free. Some WSL **Windows components** still live on the system drive; the scripts cannot relocate those components.
- The scripts intentionally do **not** automate GitHub authorization, paid or free provider credentials, worker execution, ticket processing, auto-merge, service auto-start, or a full database reset. They **never** reboot Windows, format a disk or intentionally detach a physical drive.
- Existing Ubuntu distributions at another location and existing Super Agent profiles are preserved rather than replaced.
- WSL isolation is not a strong security boundary for an agent running with upstream danger-full-access. Use a disposable VM / dedicated Windows account if you require stronger isolation.
- **Node 24 issue:** the official service script at the pinned commit may reject the process name MainThread, causing a false start timeout. Do not repeatedly start duplicate processes. Diagnose and apply only a reviewed local compatibility patch while retaining executable/profile identity checks.
- **Observed upstream tests:** one Feishu health-report test failed in the reference installation; build, typecheck and runtime plugin loading were successful. This isn't a promise of universal correctness.

## Verification and limitations

This kit was constructed from a successful step-by-step installation on Windows 11 with an external SSD in November 2026. **The combined scripts have not been end-to-end tested on a separate clean Windows machine.** Treat as a preview, verify every step and report issues on this repository.

Official [DeepSeek SETUP](https://github.com/deepseek-ai/dsh-superagent-prototype/blob/main/SETUP.md) and [Deployment](https://github.com/deepseek-ai/dsh-superagent-prototype/blob/main/docs/006-deployment.md) take precedence for upstream behavior.
