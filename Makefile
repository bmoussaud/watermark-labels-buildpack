
APP_IMAGE=myorg/cnb-nodejs
BUILDPACK_IMAGE=owner-buildpack
BUILDPACK_VERSION=0.0.3
BUILDPACK_CNB=owner-buildpack.cnb

	
inspect: buildpack
	pack inspect $(APP_IMAGE) 
	pack inspect $(APP_IMAGE) --bom

package-image: 
	pack buildpack package $(BUILDPACK_IMAGE) --config packages/package.toml 
	docker tag $(BUILDPACK_IMAGE)  harbor.mytanzu.xyz/library/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)
	docker push harbor.mytanzu.xyz/library/$(BUILDPACK_IMAGE):$(BUILDPACK_VERSION)

package-cnb:
	pack buildpack package $(BUILDPACK_CNB) --config packages/package.toml --format file

clean:
	rm $(BUILDPACK_CNB)
