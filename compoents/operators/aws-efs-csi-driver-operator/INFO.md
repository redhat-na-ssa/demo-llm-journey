# aws-efs-csi-driver-operator

AWS EFS CSI Driver Operator provides AWS Elastic File Service (EFS) CSI Driver that enables you to create and mount AWS EFS PersistentVolumes.

Please follow [AWS EFS CSI Driver Operator documentation](https://docs.openshift.com/container-platform/4.14/storage/container_storage_interface/persistent-storage-csi-aws-efs.html) to:

1. [Install the operator](https://docs.openshift.com/container-platform/4.14/storage/container_storage_interface/persistent-storage-csi-aws-efs.html#persistent-storage-csi-olm-operator-install_persistent-storage-csi-aws-efs). This section also covers details about configuring an AWS role in OCP cluster that uses Secure Token Services (STS).

2. [Install the AWS EFS CSI driver using the operator](https://docs.openshift.com/container-platform/4.14/storage/container_storage_interface/persistent-storage-csi-aws-efs.html#persistent-storage-csi-efs-driver-install_persistent-storage-csi-aws-efs)

3. Finally, [create a StorageClass](https://docs.openshift.com/container-platform/4.14/storage/container_storage_interface/persistent-storage-csi-aws-efs.html#storage-create-storage-class_persistent-storage-csi-aws-efs) that enables dynamic provisioning of PersistentVolumes.
