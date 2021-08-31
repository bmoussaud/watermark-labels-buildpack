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