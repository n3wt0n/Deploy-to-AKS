trigger:
- main

resources:
- repo: self

variables:
  imageRepo: sampleapp
  tag: '$(Build.BuildId)'

stages:
- stage: Build
  displayName: Build image
  jobs:
  - job: Build
    displayName: Build
    pool:
      vmImage: ubuntu-latest
    steps:
    - task: Docker@2
      displayName: Build an image
      inputs:
        containerRegistry: 'K8SExamplesACR'
        repository: '$(imageRepo)'
        command: 'buildAndPush'
        Dockerfile: '$(Build.SourcesDirectory)/app/Dockerfile'
        tags: |
          $(tag)
    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(Pipeline.Workspace)/s/kubernetes'
        artifact: 'manifests'
        publishLocation: 'pipeline'
        
- stage: Deploy
  displayName: Deploy to Dev
  dependsOn: Build
  variables:
    acrsecret: k8sexamplesacrauth
    acrdevurl: 'k8sexamplesacr.azurecr.io'
    replicaNo: 3
  jobs:
  - deployment: Deploy
    displayName: Deploy to AKS
    environment: 'k8sdev.default'
    pool: 
      vmImage: ubuntu-latest
    strategy:
      runOnce:
        deploy:
          steps:
          - task: DownloadPipelineArtifact@2
            inputs:
              buildType: 'current'
              artifactName: 'manifests'
              targetPath: '$(Pipeline.Workspace)/manifests'
          - task: KubernetesManifest@0
            inputs:
              action: 'createSecret'
              namespace: 'default'
              secretType: 'dockerRegistry'
              secretName: '$(acrsecret)'
              dockerRegistryEndpoint: 'K8SExamplesACR'
          - task: replacetokens@3
            displayName: Replace Tokens
            inputs:
              rootDirectory: '$(Pipeline.Workspace)/manifests/'
              targetFiles: 'deployment.yml'
              encoding: 'auto'
              writeBOM: true
              actionOnMissing: 'warn'
              keepToken: false
              tokenPrefix: '#'
              tokenSuffix: '#'
              useLegacyPattern: false
              enableTransforms: false
              enableTelemetry: true
          - task: KubernetesManifest@0
            inputs:
              action: 'deploy'
              namespace: 'default'
              manifests: |
                $(Pipeline.Workspace)/manifests/deployment.yml
                $(Pipeline.Workspace)/manifests/service.yml
              containers: '$(acrdevurl)/$(imageRepo):$(tag)'
              imagePullSecrets: '$(acrsecret)'
