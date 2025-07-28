# 🌐 Azure Static Website with VM Redirect – Terraform Setup

This Terraform project deploys:

1. An **Azure Storage Account** configured to host a **static website**.
2. A **Windows Virtual Machine** with a **public IP and port 80 open**.
3. The Windows VM runs IIS and redirects HTTP traffic to the Azure static website.

---

## 🚀 Architecture Overview

###### User (Browser) ---> Windows VM (Port 80) ---> Redirects to Azure Static Website

## 🖼 Architecture Diagram
![vm](/Images/Static_web_VM.png)

## ⚙️ Getting Started 
Clone the repository:
```
https://github.com/srinivasan2022/Static_Website_In_Azure_Storage_Account.git
```
Change the directory:
```
cd Static_Website_With_Vm
```
Deploy the resources using Terraform,
```
terraform init
```
```
terraform plan
```
```
terraform apply
```

## 🔍 Results & Screenshots
- When I browse the storage account web endpoint like https://${storage_account_name}.z13.web.core.windows.net/

![web](/Images/web02.png)

- When I browse the Public IP of the VM
 
![vm_result](/Images/vm_result.png)