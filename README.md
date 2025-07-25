# 🌐 Azure Static Website Deployments using Terraform

This repository contains two Terraform-based projects that demonstrate how to host static websites on Azure using two approaches:

```
.
├── Static_WebSite/              # Static website hosted on Azure Storage Account
│   ├── main.tf
│   ├── README.md
│
├── Static_Website_With_Vm/     # VM-based redirect to Azure static website
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│
└── README.md 
```

## 📌 Project Descriptions
###### 1️⃣ Static_WebSite

This project demonstrates how to:

- Create a Storage Account in Azure
- Enable Static Website hosting
- Upload a sample index.html to the $web container
- Ideal for simple, low-cost static web hosting scenarios.

###### 2️⃣ Static_Website_With_Vm
This project:

Creates the same Storage Account + Static Website

- Deploys a Windows Virtual Machine with public IP and IIS Web Server

- Configures the VM to redirect HTTP (port 80) traffic to the Azure static site

- Ideal if you need an on-premise-like entry point or want to simulate redirects/proxies.

## 🚀 Getting Started
- 1.Navigate into the desired subdirectory:
```
cd Static_WebSite
# OR
cd Static_Website_With_Vm
```
- 2.Run Terraform:
```
terraform init
terraform apply
```
- 3.After deployment:y
- For Static_WebSite, visit the Azure Static Website URL.

- For Static_Website_With_Vm, use the VM's public IP — it will redirect you to the static site.

## 🧹 Cleanup
To destroy all resources
```
terraform destroy
```
