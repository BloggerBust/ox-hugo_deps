FROM golang as go
FROM nauci/nauci_base_entry as nbe

MAINTAINER dustfinger@nauci.org

# copy go stuff over.
# The golang base image did a bunch of work. If we want our new image to
# reap the benefit then we must copy over the desired results.
COPY --from=go /go/ /go/
COPY --from=go /usr/local/go/ /usr/local/go/
COPY --from=go /usr/local/lib/ /usr/local/libgo

# Now let's recursively update the corresponding bin directories in
# our new image. We won't clobber existing files. There is some danger
# here, but how else is a programmer supposed to get cheap adrenaline
# thrills :-P
RUN cp -run /usr/local/libgo/* /usr/local/lib/; \
    rm -rf /usr/local/libgo/; \

    # set the path for go.
    sed -e '/^$/{s%%\n#add go to the path for interactive and non-interactive shells\nexport PATH="/usr/local/go/bin:$PATH"\n&%;:a' -e '$!N;$!ba' -e '}' /etc/bash.bashrc > /etc/bash.bashrc.bk && mv /etc/bash.bashrc.bk /etc/bash.bashrc; \

# update sources so that we can install the pandoc dependencies for hugo
    echo 'APT::Default-Release "stretch";' > /etc/apt/apt.conf.d/10Default; \
    echo 'deb http://deb.debian.org/debian buster main' >> /etc/apt/sources.list; \
    echo 'deb http://security.debian.org/debian-security buster/updates main' >> /etc/apt/sources.list; \
    echo 'deb http://deb.debian.org/debian buster-updates main' >> /etc/apt/sources.list; \

# Update the apt cache, packages and upgrade stable
    apt-get -qqy update; \
    apt-get -qqy upgrade; \
    apt-get -qqy dist-upgrade; \

# Install pandoc dependencies from buster since that contains the version we need
    apt-get -qqy -t buster install pandoc pandoc-citeproc; \
    apt-get -qqy install git; \
    apt-get clean;