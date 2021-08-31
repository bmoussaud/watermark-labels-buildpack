APP_IMAGE=myorg/java-app

BUILDPACK_IMAGE=watermark-labels-buildpack
BUILDPACK_VERSION=0.0.4
BUILDPACK_CNB=watermark-labels-buildpack.cnb
REMOTE_REGISTRY= harbor.mytanzu.xyz/library

inspect: buildpack
	pack inspect $(APP_IMAGE) 
	pack inspect $(APP_IMAGE) --bom

package-buildpack: 
	pack buildpack package $(BUILDPACK_IMAGE) --config buildpack/package.toml 
	docker tag $(BUILDPACK_IMAGE)  $(REMOTE_REGISTRY)/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)
	docker push $(REMOTE_REGISTRY)/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)

package-cnb:
	pack buildpack package $(BUILDPACK_CNB) --config package.toml --format file

clean:
	rm $(BUILDPACK_CNB)

package-app:
	pack build $(APP_IMAGE) --path sampleapp

watermark-local-package-app:
	pack build $(APP_IMAGE) --path sampleapp --buildpack buildpack
	docker inspect $(APP_IMAGE) | grep watermark.instance
	docker inspect $(APP_IMAGE) | grep watermark.host


watermark-image-package-app:package-buildpack 
	pack build $(APP_IMAGE) --path sampleapp --buildpack $(REMOTE_REGISTRY)/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)
	docker inspect $(APP_IMAGE) | grep watermark.instance
	docker inspect $(APP_IMAGE) | grep watermark.host