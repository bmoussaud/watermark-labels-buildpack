# Watermark buildpack

## goal

## process

* Build the buildpack as an image  

````
make package-buildpack
````

* Build the sample application 

````
make package-app
````

* Build the sample application using `watermark` buildpack locally

````
make watermark-local-package-app
````

* Build the sample application using `watermark` buildpack built as a image pushed on a remote regsitry

````
make watermark-local-package-app
````

* Build the sample application using `watermark` buildpack and `kpack` 

````
make watermark-kpack-package-app
````

the Make apply the resources defined in the `kpack` directory into the `kpack` namespace already configured.
The resources are
    * a custom `ClusterStore` that includes the buildpack to use : common buildpacks from paketo and the `watermark` buildpack
    * a custom `Builder` that combines the stack, the store and the order of the applied buildpack
    * a custom `Image`that creates the link between the source (git) and the builder.

the output is 

````
= package-buildpack
pack buildpack package watermark-labels-buildpack --config buildpack/package.toml
Successfully created package watermark-labels-buildpack
docker tag watermark-labels-buildpack  harbor.mytanzu.xyz/library/watermark-labels-buildpack:0.0.4
docker push harbor.mytanzu.xyz/library/watermark-labels-buildpack:0.0.4
The push refers to repository [harbor.mytanzu.xyz/library/watermark-labels-buildpack]
99c5528091ee: Layer already exists
0.0.4: digest: sha256:54d777531e83dbb0ad17a0353ef8b37f797dbcdaf0da9230e77d811f2b1a73d7 size: 523

= watermark-kpack-package-app
kubectl apply -f kpack/01-store.yml
clusterstore.kpack.io/my-customized-clusterstore created
kubectl wait --for=condition=ready --timeout=30s  clusterstore/my-customized-clusterstore
clusterstore.kpack.io/my-customized-clusterstore condition met
kubectl get ClusterStore  my-customized-clusterstore
NAME                         READY
my-customized-clusterstore   True

kubectl apply -f kpack/02-builder.yml
builder.kpack.io/my-watermark-springboot-builder created
kubectl wait --for=condition=ready --timeout=30s -n kpack Builder/my-watermark-springboot-builder
builder.kpack.io/my-watermark-springboot-builder condition met
kubectl get Builder -n kpack my-watermark-springboot-builder
NAME                              LATESTIMAGE                                                                                                                          READY
my-watermark-springboot-builder   harbor.mytanzu.xyz/library/my-watermark-springboot-builder@sha256:503f5243137568d6330a4a951516c0133c2d9f91c83cac49dffb8bca6d545847   True

kubectl apply -f kpack/03-image.yml
image.kpack.io/my-watermark-sampleapp-image created
kubectl wait --for=condition=ready --timeout=90s -n kpack Image/my-watermark-sampleapp-image
image.kpack.io/my-watermark-sampleapp-image condition met
kubectl get images -n kpack my-watermark-sampleapp-image
NAME                           LATESTIMAGE                                                                                                                 READY
my-watermark-sampleapp-image   harbor.mytanzu.xyz/library/my-watermark-sampleapp@sha256:40751f0679bf7cdb009d16e01b338f115497532d6aa904aa4e2aa954fc202ced   True

docker pull harbor.mytanzu.xyz/library/my-watermark-sampleapp
Using default tag: latest
latest: Pulling from library/my-watermark-sampleapp
d6610dacf072: Already exists
4c007ebee298: Already exists
.....
59e2443736a1: Pull complete
b39b18afe74e: Pull complete
Digest: sha256:40751f0679bf7cdb009d16e01b338f115497532d6aa904aa4e2aa954fc202ced
Status: Downloaded newer image for harbor.mytanzu.xyz/library/my-watermark-sampleapp:latest
harbor.mytanzu.xyz/library/my-watermark-sampleapp:latest
docker inspect harbor.mytanzu.xyz/library/my-watermark-sampleapp | grep watermark.instance
                "watermark.instance": "mycompany-instance-one",
docker inspect harbor.mytanzu.xyz/library/my-watermark-sampleapp | grep watermark.host
                "watermark.host": "my-watermark-sampleapp-image-build-1-8dmmn-build-pod"
docker inspect harbor.mytanzu.xyz/library/my-watermark-sampleapp | grep watermark.author
                "watermark.author": "benoitmoussaud",
````
