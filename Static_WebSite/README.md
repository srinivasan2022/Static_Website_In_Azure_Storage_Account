# Static_Website_In_Azure_Storage_Account :

Azure Blob Storage is ideal for storing large amounts of unstructured data such as text, images, and videos. Because blob storage also provides static website hosting support, it's a great option in cases where you don't require a web server to render content. Although you're limited to hosting static content such as HTML, CSS, JavaScript, and image files, you can use serverless architectures including Azure Functions and other Platform as a service (PaaS) services.

## Architecture Diagram :
![web](Images/web.png)

###### Apply the Terraform configurations :

Deploy the resources using Terraform,
```
cd Static_Website
```
```
terraform init
```
```
terraform plan
```
```
terraform apply
```

Further steps :
- 1.First we create the Resource Group (staticweb-rg").
- 2.Next , we create the Storage account.
- 3.In Storage , Click Static Website , Enable the Static Website and index document name index.html , Error document path 404.html and Click Save.
- 4.Got the Static Website Primary endpoint like https://${storage_account_name}.z13.web.core.windows.net/
- 5.We have the new Container named $web which is automatically created.
- 6.In $web Container , upload the index.html file which is in your local directory.
- 7.Finally , browse the Primary endpoint like https://${storage_account_name}.z13.web.core.windows.net/ then we got the Static Website.

## Screenshot :

![Web](/Images/website.png)