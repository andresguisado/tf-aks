# Terraform Project: Azure Kubernetes Service (AKS)

**Description:** Terraform project calling to an Azure Kubernetes Service (AKS) module in order to build an initial platform for developers.

**Output:** An AKS cluster in an Azure managed vNet, with the parent Container Service object in an Azure custom resource group. 

## Project Structure

```bash
|-- .gitignore
|-- tf
|-- src
|-- main.tf
|-- provider.tf
|-- variables.tf
|-- tf.sh
```
### File Descriptions

**Filename**|**Description**
-----|-----
[tf/src/main.tf](tf/src/main.tf) | TF file where we set-up our module configuration needed to build the K8s platform.
[tf/src/provider.tf](tf/src/provider.tf) | TF file with our azure provider configuration.
[tf/src/variables.tf](tf/src/variables.tf) | TF file with the variables needed to build the k8s platform.
[tf.sh](tf/src/variables.tf) | Bash script to build the k8s platform.

## Module Usage

Please, see further information here:

[tfmodule-aks](https://github.com/andresguisado/tfmodule-aks/tree/aks-with-existing-spn)

## Usage

We are looking at containerizing terraform to be able to create azure resources from a container, but in the meantime, in order to **create** this TF project you can run this command:

```sh tf.sh -a -n aks-ag01 -c```

In order to **destroy** as follows:

```sh tf.sh -d -n aks-ag01 -c```


Authors
=======
Originally created by [Andres Guisado](http://github.com/andresguisado)


