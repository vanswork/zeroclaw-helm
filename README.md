# zeroclaw-helm

Custom ZeroClaw runtime image + Helm chart for coding-capable deployments.

## Why this exists

The upstream production image is distroless, so binaries like `sh`, `bash`, `git`, and `gh` are not present.
This repo provides:

- A custom image with shell and Git tooling
- A Helm chart that deploys ZeroClaw daemon with config/secret injection

## Custom image

`Dockerfile` builds from `ghcr.io/zeroclaw-labs/zeroclaw:v0.1.7` and layers a Debian Trixie runtime with:

- `bash`, `coreutils`, `git`, `gh`, `openssh-client`
- non-root execution (`65534:65534`)
- `tini` as PID 1

Build locally:

```bash
docker build -t ghcr.io/<your-org>/zeroclaw-coder:dev .
docker push ghcr.io/<your-org>/zeroclaw-coder:dev
```

GitHub Actions workflow (`.github/workflows/docker-image.yml`) pushes multi-arch images to:

`ghcr.io/<repo-owner>/zeroclaw-coder`

## Helm chart

Chart path: `charts/zeroclaw`

### Quick install

```bash
helm upgrade --install zeroclaw charts/zeroclaw -n zeroclaw --create-namespace
```

### Set your own image tag

```bash
helm upgrade --install zeroclaw charts/zeroclaw -n zeroclaw \
  --set image.repository=ghcr.io/<your-org>/zeroclaw-coder \
  --set image.tag=<tag>
```

### Optional: Discord token injection

1) Create a secret:

```bash
kubectl create secret generic zeroclaw-secrets -n zeroclaw \
  --from-literal=discord-bot-token='<token>'
```

2) Enable in values:

```yaml
secrets:
  create: false
  name: zeroclaw-secrets

discord:
  enabled: true
```

3) Ensure your `config.template` includes:

```toml
[channels_config.discord]
bot_token = "__DISCORD_BOT_TOKEN__"
allowed_users = ["*"]
mention_only = true
listen_to_bots = false
```

### Optional: GitHub App private key mount

Use existing secret:

```bash
kubectl create secret generic zeroclaw-github-app -n zeroclaw \
  --from-file=private-key.pem=./app.private-key.pem
```

Set values:

```yaml
githubApp:
  enabled: true
  privateKeySecretName: zeroclaw-github-app
  privateKeyFileName: private-key.pem
  appId: "123456"
  org: your-org
```

When `githubApp.enabled=true`, the chart also configures a global Git credential helper during init.
The helper mints a short-lived GitHub App installation token on demand, so plain HTTPS `git clone https://github.com/<org>/<repo>` works for private repositories without interactive `gh auth login`.

## Notes

- Default chart values are tuned for autonomous coding throughput.
- Review `charts/zeroclaw/values.yaml` before production rollout.
- Do not commit real secrets into git.
