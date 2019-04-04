tag:
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" Chart.yaml
	sed -i "" -e "s/tag: .*/tag: $(VERSION)/" values.yaml
else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" Chart.yaml
	sed -i -e "s/tag: .*/tag: $(VERSION)/" values.yaml
else
	echo "platfoom $(OS) not supported to tag with"
	exit -1
endif