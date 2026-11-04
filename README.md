# DeepSeek Super Agent — TunnelLab Setup Guide

An independent, bilingual installation website for **DeepSeek Super Agent**. Covers Windows 11, external SSD, Ubuntu WSL2, DeepSeek Harness, OpenRouter, and the upstream Super Agent bundle.

## Guides

- **Agent-assisted:** a single continuous Codex prompt, linked from the page, with permission checkpoints and restart-safe continuation. The [installer kit](installer/) includes actual Windows/Ubuntu scripts.
- **Manual:** PowerShell + Ubuntu commands, the reviewed [PowerShell bootstrap](installer/install.ps1) and [Linux setup script](installer/setup-linux.sh), plus secure account/configuration checkpoints.
- **Model provider:** OpenRouter custom API setup, with free-model compatibility caveats.
- **Verification:** practical test and security checklist.

Site: `index.html`. No build step or external JS dependencies.

**Installer status:** preview. The consolidated scripts are published but have not been tested end-to-end on a fresh Windows machine. See [installer/README.md](installer/README.md) for supported versions, operator-only secrets, permissions, and limits.

## Launch

Enable **Settings → Pages → Deploy from a branch → main / (root)** in this repository if Pages is not already active.

Expected Pages URL after enabling:
https://pouramin.github.io/dshsuperagent/

If using a custom `pouramin.dev` route, configure it separately in the hosting provider and verify that it serves this repository before sharing it.

## Design system

See [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md). The page follows TunnelLab's newer light UI visual language (Mercury / REA-Codex): DM Sans, Vazirmatn, off-white canvas, navy copy, blue and orange accents, rounded white cards, copyable code blocks.

## Security

The upstream Executor and Router presets use `danger-full-access`. WSL is not a strong security boundary. Use a dedicated account or VM for stronger isolation, separate GitHub bot credentials, disposable repos, review-before-merge, and a least-privileged operator.

The Codex workflow requires inspection and explicit approval before install, with separate authorization for elevation or reboots. Windows is never intentionally rebooted by the scripts. The website itself cannot run system commands.

## Upstream references

- https://github.com/deepseek-ai/dsh-superagent-prototype/blob/main/SETUP.md
- https://github.com/deepseek-ai/dsh-superagent-prototype/blob/main/docs/006-deployment.md
- https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.md
- https://learn.microsoft.com/en-us/windows/wsl/basic-commands

This is a community educational site, not affiliated with DeepSeek.
