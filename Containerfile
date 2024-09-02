FROM ghcr.io/prefix-dev/pixi:bookworm-slim
USER root
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends vim unzip ca-certificates \ 
    openssh-server iproute2 libcurl4-openssl-dev build-essential libxml2-dev curl apt-utils\
    unixodbc-dev libgssapi-krb5-2 gnupg iputils-ping git default-jre xsel xclip jq

# MSODBC in Debian 12
RUN curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
RUN sed -i 's/signed-by=\/usr\/share\/keyrings\/microsoft-prod.gpg//' /etc/apt/sources.list.d/mssql-release.list
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

# RUN pixi run install -e prod
# # Create the shell-hook bash script to activate the environment
# RUN pixi shell-hook -e prod > /shell-hook.sh
# RUN pixi shell-hook > $HOME/shell-hook.sh

# # # extend the shell-hook script to run the command passed to the container
# RUN echo 'exec "$@"' >> $HOME/shell-hook.sh

CMD ["/bin/bash"]