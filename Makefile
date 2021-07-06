
APP_IMAGE=myorg/cnb-nodejs
BUILDPACK_IMAGE=owner-buildpack
BUILDPACK_VERSION=0.0.3
BUILDPACK_CNB=owner-buildpack.cnb

# pack config default-builder gcr.io/paketo-buildpacks/builder:base
buildpack:
	pack build $(APP_IMAGE) --builder paketobuildpacks/builder:base --buildpack ./mycompany-owner-buildpack

buildpack-image-labels:
	pack build $(APP_IMAGE) --builder paketobuildpacks/builder:base --buildpack paketo-buildpacks/image-labels	-e BP_IMAGE_LABELS=kpack.builder.hostname=gimmick,kpack.builder.instance=tbs-1
	
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
