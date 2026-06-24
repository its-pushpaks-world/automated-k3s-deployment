# Fully Automated E2E Infrastructure & K3s GitOps Pipeline

This repository hosts a production-grade, single-command continuous deployment (CD) ecosystem. It fully automates both the cloud infrastructure orchestration and application availability layers using a streamlined, pull-request-driven lifecycle.

---

## 🏗️ Architectural Overview

The framework processes operations fluidly across three native, interconnected layers without requiring manual hand-offs or custom configuration editing:

1. **Infrastructure Automation Layer:** Managed under the `infrastructure/` directory using Terraform. It provisions a clean network security envelope, maps target ingress paths, spins up a high-performance compute node, and passes system setup data via user scripts.
2. **Decoupled Application Layer:** Located under the `K3s-manifests/` directory. It maintains pure, declarative Kubernetes objects (ConfigMaps, Deployments, and NodePort access mappings) completely separated from build or system infrastructure dependencies.
3. **Continuous Orchestration Engine:** Managed by GitHub Actions. The pipeline monitors repository scopes, automatically provisions cloud infrastructure, securely establishes SSH tunnels to retrieve transient cluster assets, dynamically translates network parameters, and reconciles state variables automatically.

```
[ Code Change / PR ] ---> GitHub Actions Runner
                               |
                               +---> Step 1: Run Terraform Apply (infrastructure/)
                               |     (Creates AWS VM & Installs K3s Cluster)
                               |
                               +---> Step 2: Extract Live SSH Key & Fetch K3s Config
                               |     (Dynamically maps remote cluster context)
                               |
                               +---> Step 3: Execute Remote Apply (K3s-manifests/)
                                     (Deploys Application Live to Cloud)
```

---

## 📁 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml                                       # Combined E2E Infrastructure & App Pipeline
├── infrastructure/
│   └── main.tf                                              # Terraform Script (Dynamic SSH Key, EC2, K3s Bootstrap)
├── K3s-manifests/
│   └── nginx-deployment.yaml                                # Declarative Application Manifest File
├── recordings/                                              # Project Execution & Demonstration Media
│   ├── Part_1_Install_k3s_on_a_Linux_Machine                # Infrastructure Bootstrapping Recording
│   ├── Part_2_Deploy_Hello World_Nginx_Application          # Local Manifest Validation Verification
│   └── Part_3_Set_Up_Git_Pipeline_for_Automatic_Deployment  # End-to-End Pull Request Run Proof
└── README.md                                                # System Architecture and Operational Overview
```

---

## 🎥 Video Demonstration / Recordings

The complete technical execution, verification, and automated pipeline lifecycle are recorded and stored directly within this repository:

* **[Part 1: Install k3s on a Linux Machine]** – Walkthrough of the automated AWS EC2 compute instance setup and the K3s cluster bootstrap sequence via Terraform.

https://github.com/user-attachments/assets/2d6523f6-4d3e-48dc-ab71-78734b40da90

* **[Part 2: Deploy "Hello World" Nginx Application]** – Verification of the native Kubernetes resources, verifying the decoupled ConfigMap storage layer and internal network boundary.

https://github.com/user-attachments/assets/4ff83f60-5265-491a-b83d-48752ef828f1

* **[Part 3: Set Up Git Pipeline for Automatic Deployment]** – Live demonstration of opening the Pull Request, path-filtered pipeline triggering, programmatic authentication mapping, and successful cluster state synchronization.

https://github.com/user-attachments/assets/4b680254-f994-4f3b-91b2-2bc1390b6853

---

## 🔐 Required Pipeline Credentials

To allow the automation engine to talk securely to AWS, you only need to define your main cloud connection parameters. Manual tracking of IP addresses or Kubernetes credential strings is no longer required.

Navigate to **Settings → Secrets and variables → Actions** in your GitHub repository interface and configure the following parameters:

* **Repository Secret (`AWS_ACCESS_KEY_ID`):** Your AWS programmatic access key.
* **Repository Secret (`AWS_SECRET_ACCESS_KEY`):** Your AWS programmatic secret string.

---

## 🚀 Execution & Pipeline Testing

Because the repository structure and path filtering are already established, you can test the pipeline automation directly by modifying the deployment parameters on a feature branch.

#### Step 1: Create a Feature Branch and Modify the Manifest
Run these commands in your terminal to switch to a feature branch and apply a configuration update inside the existing manifests directory:

```bash
# 1. Create and switch to a new feature branch
git checkout -b feature/test-k3s-pipeline

# 2. Make an update to the manifest (e.g., modifying replica count or adding a deployment comment)
echo "# Pipeline verification update" >> K3s-manifests/nginx-deployment.yaml
```

#### Step 2: Commit and Push the Changes
Stage the updated manifest file and push the tracking branch to GitHub:

```bash
# 1. Stage the modified manifest
git add K3s-manifests/nginx-deployment.yaml

# 2. Commit the change
git commit -m "test: trigger path-filtered PR workflow update"

# 3. Push the feature branch to the remote repository
git push origin feature/test-k3s-pipeline
```

#### Step 3: Open the Pull Request
1. Go to your GitHub repository dashboard in your web browser.
2. Click the **Compare & pull request** button that automatically populates for your pushed branch.
3. Verify that the target base branch is set to `main` and submit the Pull Request.
4. The workflow will instantly trigger under the **Checks** tab of the PR window, programmatically authenticating with your remote EC2 server and executing the deployment.
5. Once the check reports a successful execution, test the public-facing route to verify live ingress traffic:
   ```text
   http://<YOUR_EC2_PUBLIC_IP>:30080
   ```

---

## 💎 Architectural Discussion (Push vs. Pull-Based GitOps)

The mechanism implemented here operates as an advanced **Push-Based Pipeline via PR Validation**. The automation cluster agent actively accesses the tracking repository's context, builds local kubeconfig frames, and pushes configuration updates across the public internet network grid onto API Port `6443`.

While this model provides deep insight into state changes during verification and pull request approval workflows, high-velocity corporate environments typically mature into **Pull-Based GitOps Models** (utilizing inside-the-cluster management runtimes like **ArgoCD** or **FluxCD**).

### Strategic Advantages of the Pull-Based Evolution:
* **Secured Perimeter Footprints:** Cluster control planes eliminate public internet port exposures (Port `6443`). Internal network operators pull state updates securely over outbound standard HTTPS channels.
* **Secret Sprawl Elimination:** Centralized cloud execution nodes no longer store persistent configuration profiles or master admin credentials.
* **Active Drift Self-Healing:** The system engine continually compares live runtime environments against the tracking source-of-truth. If human intervention alters states via native CLI controllers, the GitOps loops actively identify the configuration variance and apply rollbacks to restore target tracking structures automatically.
```
