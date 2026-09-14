# azure-app-placeholder

Minimal placeholder app: a React UI with one button that calls a .NET API and shows the response. Used as a target for a future self-healing/monitoring project.

- `api/` — .NET 10 minimal Web API (`api.csproj`, `api.slnx`), single `GET /api/status` endpoint.
- `ui/` — React + TypeScript (Vite), one button that calls the API.
- `infra/` — Bicep to deploy both to Azure (App Service for the API, Static Web App for the UI).

## Run locally

API (from `api/`):

```
dotnet run --launch-profile https
```

Runs on `https://localhost:7085`.

UI (from `ui/`):

```
npm install
npm run dev
```

Runs on `http://localhost:5173` and reads the API URL from `ui/.env` (`VITE_API_BASE_URL`).

## Deploy to Azure

```
az group create -n <resource-group> -l westeurope
az deployment group create -g <resource-group> -f infra/main.bicep -p infra/main.bicepparam
```

Then:

1. Publish the API to the App Service named in the deployment output (`apiAppName`), e.g. `dotnet publish -c Release` + zip deploy, or `az webapp deploy`.
2. Build the UI with `VITE_API_BASE_URL` set to the deployment's `apiUrl` output, then deploy `ui/dist` to the Static Web App (`staticWebAppName`), e.g. via the [SWA CLI](https://azure.github.io/static-web-apps-cli/) or GitHub Actions.
