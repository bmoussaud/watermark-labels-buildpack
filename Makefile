APP_IMAGE=myorg/cnb-nodejs

BUILDPACK_IMAGE=watermark-labels-buildpack
BUILDPACK_VERSION=0.0.3
BUILDPACK_CNB=watermark-labels-buildpack.cnb

inspect: buildpack
	pack inspect $(APP_IMAGE) 
	pack inspect $(APP_IMAGE) --bom

package-image: 
	pack buildpack package $(BUILDPACK_IMAGE) --config buildpack/package.toml 
	docker tag $(BUILDPACK_IMAGE)  harbor.mytanzu.xyz/library/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)
	docker push harbor.mytanzu.xyz/library/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)

package-cnb:
	pack buildpack package $(BUILDPACK_CNB) --config package.toml --format file

clean:
	rm $(BUILDPACK_CNB)
