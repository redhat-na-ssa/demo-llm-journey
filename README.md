# demo-llm-journey

Demo LLM things

## Quick Start

```sh
until oc apply -k bootstrap; do : ; done
```

## Notes

Patch `MachineSet` to add secondary storage

```sh
spec:
  template:
    spec:
      providerSpec:
        value:
          blockDevices:
            - ebs:
                encrypted: true
                iops: 0
                kmsKey:
                  arn: ''
                volumeSize: 100
                volumeType: gp3
            - deviceName: /dev/xvdb
              ebs:
                encrypted: true
                iops: 0
                kmsKey:
                  arn: ''
                volumeSize: 1000
                volumeType: gp3
```

## Related Links

- 