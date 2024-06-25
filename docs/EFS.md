# EFS Storage on OpenShift

Some of the Open-Metadata components have a requirement for cluster storage that supports ReadWriteMany and ReadOnceMany, for example AirFlow has [this warning](https://github.com/airflow-helm/charts/blob/main/charts/airflow/values.yaml#L1355):

```yaml
    ## the access mode of the PVC
    ## - [WARNING] must be "ReadOnlyMany" or "ReadWriteMany" otherwise airflow pods will fail to start
    ##
    accessMode: ReadOnlyMany
```

The default cluster storage class (gp3-csi) doesn’t support this option, so we must install a different operator for storage. More information in a [Red Hat Support Note](https://access.redhat.com/solutions/7013179) indicates that the AWS EBS CSI driver only supports the ReadWriteOnce access mode, which won’t work for our installation.

There are a number of options available, some tied to specific cloud providers such as AWS or Azure specific storage operators. More information can be found at: [Understanding Persistent Storage](https://docs.openshift.com/container-platform/4.14/storage/understanding-persistent-storage.html#pv-access-modes_understanding-persistent-storage) in the OpenShift documentation (click the “Access Modes” link at right panel to see a table of options).

For our AWS cluster, we decided to use the [AWS Elastic File Service CSI Driver Operator](https://docs.openshift.com/container-platform/4.14/storage/container_storage_interface/persistent-storage-csi-aws-efs.html). 

## Installation Steps

Installation of EFS StorageClass on an OpenShift cluster consists of the following steps:

1. Install the AWS EFS CSI Operator

    a. Click **Operators -> OperatorHub**

    b. Locate the AWS EFS CSI Operator by typing "AWS EFS CSI" in the filter box

    c. Select the **AWS EFS CSI Driver Operator** from the result

    d. On the **AWS EFS CSI Driver Operator** page, click **Install**

    e. On the **Install Operator** page, ensure that:

      - All namespaces on the cluster (default) is selected
      - Installed Namespace is set to **openshift-cluster-csi-drivers**

    f. Click **Install**

2. Install the AWS EFS CSI Driver

    a. Click **administration -> CustomResourceDefinitions -> ClusterCSIDriver**

    b. On the **Instances** tab, click **Create ClusterCSIDriver**

    c. Use the following YAML file:

    ```yaml
    apiVersion: operator.openshift.io/v1
    kind: ClusterCSIDriver
    metadata:
        name: efs.csi.aws.com
    spec:
        managementState: Managed
    ```

    d. Click **Create**

    e. Wait for the following Conditions to change to a "true" status:

      - AWSEFSDriverCredentialsRequestControllerAvailable
      - AWSEFSDriverNodeServiceControllerAvailable
      - AWSEFSDriverControllerServiceControllerAvailable

3. Configure access to EFS volumes in AWS

    a. Go to https://console.aws.amazon.com/efs#/file-systems and ensure you are in the correct AWS region for your cluster (us-east-1).

    b. Create a new volume, then click your volume and on the Network tab ensure that all mount targets are available.

    c. On the Network tab, copy the Security Group ID (you will need this in the next step).

    d. Go to https://console.aws.amazon.com/ec2/v2/home#SecurityGroups, and find the Security Group used by the EFS volume.

    e. On the Inbound rules tab, click Edit inbound rules, and then add a new rule with the following settings to allow OpenShift Container Platform nodes to access EFS volumes:

      - Type: **NFS**
      - Protocol: **TCP**
      - Port range: **2049**
      - Source: CIDR range for your cluster's VPC (e.g. **"10.0.0.0/16"**)

    f. Save the rule.

4. Create the AWS EFS storage class using the OpenShift web console

    a. In the OpenShift Container Platform console, click **Storage → StorageClasses**.

    b. On the **StorageClasses** page, click **Create StorageClass**. Click the **Edit YAML** tab to manually edit the content. 

    Note that the Web UI doesn’t provide data entry for the additional parameters we require, which is why we [manually enter the following YAML](https://docs.openshift.com/rosa/storage/container_storage_interface/osd-persistent-storage-aws-efs-csi.html#storage-create-storage-class-cli_osd-persistent-storage-aws-efs-csi), make sure to enter the correct **fileSystemId** for your cluster.

    ```yaml
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: efs
    provisioner: efs.csi.aws.com
    parameters:
      provisioningMode: efs-ap 
      fileSystemId: fs-02e4dc93b213cbb0e < Update this
      directoryPerms: "700" 
      gidRangeStart: "50000" 
      gidRangeEnd: "7000000" 
      basePath: "/dynamic_provisioning" 
    ```

    c. Click **Create**.

## Additional EFS References

* [AWS EFS CSI Driver Operator installation guide in OCP](https://access.redhat.com/articles/6966373?band=se&seSessionId=74c3365b-af7e-4101-b940-7bfd80f9264c&seSource=Recommendation&seResourceOriginID=644b2265-2b00-469a-9876-108f16ba7976)

* [SAML: AWS CLI Access](https://source.redhat.com/departments/it/devit/it-infrastructure/itcloudservices/itpubliccloudpage/cloud/docs/consumer/using_ansible_and_the_cli_to_access_aws_in_a_saml_world)

* [AWS Elastic File Service CSI Driver Operator](https://docs.openshift.com/container-platform/4.14/storage/container_storage_interface/persistent-storage-csi-aws-efs.html)
