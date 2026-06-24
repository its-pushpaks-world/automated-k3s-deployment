# Pull-Request-Driven Automated K3s Deployment Pipeline

This repository hosts a production-grade continuous deployment (CD) architecture. It manages a cloud-native single-node Kubernetes cluster (K3s) on AWS infrastructure using targeted automation. The pipeline leverages scoped GitHub Actions event triggers to isolate infrastructure mutations strictly to code review cycles.

---

## 🏗️ Architectural Overview

The architecture minimizes pipeline execution overhead by implementing event-driven and path-specific filters:

1. **Isolation Layer:** The application's declarative states are decoupled from repository tracking configurations and localized entirely inside the `K3s-manifests/` directory.
2. **Pull-Request Gatekeeping:** Infrastructure alterations do not auto-apply on general pushes. The execution engine evaluates modifications *only* during an active Pull Request context targeting `main`.
3. **Automated Dynamic Auth Alignment:** The CI/CD runner ingests raw Kubernetes cluster configuration strings, strips structural x509 certificate validation boundaries programmatically, maps remote ingress locations dynamically via Repository Variables, and handles atomic target state matching.

```
[ Feature Branch ] ---> Open PR ---> [ Filter Checklist Evaluated ]
                                                 |
                                     (Path: K3s-manifests/** ?)
                                                 |
                                                 v
[ AWS Cloud EC2 Node ] <--- Remote Apply <--- [ CI/CD Runner Engine ]
```

---

## 📁 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # Scoped Pull Request Pipeline Configuration
├── K3s-manifests/
│   └── nginx-deployment.yaml   # Native Kubernetes Decoupled Manifest File
└── README.md                   # Automation Guide & Architectural Summary
```

---

## 🔐 Setup, Secrets & Variables Wiring

To run the remote deployment suite, authorization parameters must be mapped inside your GitHub Repository configuration suite prior to launching validation tracks.

### 1. Terminal Credentials Persistence
Ensure local working environments are synchronized with Git configuration boundaries to enable non-interactive workspace sync loops:
```bash
git init
git branch -M main
git remote add origin [https://github.com/](https://github.com/)<your-username>/<your-repo-name>.git
git config --global credential.helper store
```

### 2. GitHub Actions Context Injectors
Navigate to **Settings → Secrets and variables → Actions** in your repository dashboard and define the following infrastructure values:

* **Repository Secret (`KUBECONFIG`):** Execute `sudo cat /etc/rancher/k3s/k3s.yaml` inside your running cluster instance terminal. Copy the exact raw output string blocks and paste them straight into the secret value block.
* **Repository Variable (`EC2_PUBLIC_IP`):** Navigate to the Variables tab and map your active instance public-facing IPv4 address (e.g., `13.62.103.239`).

---

## 🚀 Execution & Verification Pipeline

Because this architecture enforces strict branch-protection logic, the pipeline requires an explicit pull request validation cycle to trigger.

### Step 1: Stage Changes on a Feature Branch
```bash
# Branch out to isolate development tracks
git checkout -b feature/manifest-updates

# Ensure changes are located inside the filtered directory
mkdir -p K3s-manifests
mv nginx-deployment.yaml K3s-manifests/

# Stage, commit, and push features to the remote branch
git add .
git commit -m "feat: localize manifests and target pr pipeline scope"
git push origin feature/manifest-updates
```

### Step 2: Triggering and Validating the Lifecycle
1. Open your GitHub repository web browser interface and select **Compare & pull request** targeting the `main` branch.
2. The `Deploy Nginx to K3s` workflow will trigger instantly under the Pull Request check mechanisms.
3. Review the live log timeline in the **Actions** menu to trace the programmatic text substitutions, credential setups, and cluster reconciliation blocks.
4. Once the check succeeds, query the endpoint directly to verify ingress traffic flow:
   ```text
   http://<YOUR_EC2_PUBLIC_IP>:30080
   ```

---

## 💎 Architectural Discussion (Push vs. Pull-Based GitOps)

The mechanism implemented here operates as a **Push-Based Pipeline via PR Validation**. The automation cluster agent actively accesses the tracking repository's context, builds local kubeconfig frames, and pushes configuration updates across the public internet network grid onto API Port `6443`.

While this model provides deep insight into state changes during verification and pull request approval workflows, high-velocity corporate environments typically mature into **Pull-Based GitOps Models** (utilizing inside-the-cluster management runtimes like **ArgoCD** or **FluxCD**).

### Strategic Advantages of the Pull-Based Evolution:
* **Secured Perimeter Footprints:** Cluster control planes eliminate public internet port exposures (Port `6443`). Internal network operators pull state updates securely over outbound standard HTTPS channels.
* **Secret Sprawl Elimination:** Centralized cloud execution nodes no longer store persistent configuration profiles or master admin credentials.
* **Active Drift Self-Healing:** The system engine continually compares live runtime environments against the tracking source-of-truth. If human intervention alters states via native CLI controllers, the GitOps loops actively identify the configuration variance and apply rollbacks to restore target tracking structures automatically.
