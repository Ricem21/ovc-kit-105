# Use the kit 105.1.2 streaming base image available publicly via NVIDIA NGC
FROM nvcr.io/nvidia/omniverse/kit:105.1.2

###
### This section of code defines variable inputs to `docker build`
###
ARG FAT_PACK
ARG OVC_KIT

RUN if [  -z $FAT_PACK ];then \
>&2 echo  "\n****************Warning!!!!*************\n"; \
>&2 echo "Define docker build --build-arg FAT_PACK=<path_to_your_fat_package>.zip, it cannot be empty!" ; false;\
fi

RUN if [  -z $OVC_KIT ];then \
>&2 echo  "\n****************Warning!!!!*************\n"; \
>&2 echo "Define docker build --build-arg OVC_KIT=<some.file.ovc.kit>, it cannot be empty!" ; false;\
fi

ENV OVC_KIT=$OVC_KIT
ENV OVC_APP_PATH="/opt/nvidia/omniverse"

### Cleanup embedded kit-sdk-launcher package as your custom application is already a full package with kit-sdk.
RUN rm -rf /opt/nvidia/omniverse/kit-sdk-launcher

### Copy the application package from the _build/packages directory into the containers OV app directory.
COPY --chown=ubuntu:ubuntu $FAT_PACK $OVC_APP_PATH

### Unzip the application package into the container's /app directory and then delete the application package.
WORKDIR $OVC_APP_PATH
RUN echo $OVC_APP_PATH
RUN FAT_PACK_BASE=$(basename $FAT_PACK) && unzip $FAT_PACK_BASE -d . && rm $FAT_PACK_BASE

# Pull in any additional required dependencies.
RUN ./pull_kit_sdk.sh

# Copy the startup.sh script from the repos source/scripts directory.
# This is what will be called when the container image is started.
COPY --chown=ubuntu:ubuntu startup.sh /startup.sh
RUN chmod +x /startup.sh

# This specifies the container's default entrypoint that will be called by "> docker run".
ENTRYPOINT [ "/startup.sh" ]

# Create local user configuration folder
RUN mkdir -p ~/.nvidia-omniverse/config
