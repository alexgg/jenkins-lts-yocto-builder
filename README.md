# jenkins-lts-yocto-builder
A jenkins-lts based Yocto builder docker container

# Clone the jenkins data folder
```
cd <workdir>
git clone git@github.com:alexgg/jenkins-data.git .
```

# Usage
```
docker run -p 8080:8080 -p 50000:50000 -v <workdir>:/var/jenkins_home --privileged aggurio/jenkins-lts-yocto-builder
```

For example:
```
docker run -p 8080:8080 -p 50000:50000 -v /var/jenkins:/var/jenkins_home --privileged aggurio/jenkins-lts-yocto-builder
```

Notice that <workdir> folder we have pre-populated before is mounted as a volume to the jenkins container.

# Plugin update

After installing new plugins, the plugins.txt file can be re-generated as follows:

```
JENKINS_HOST=alex:pw@localhost:8080
curl -sSL "http://$JENKINS_HOST/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/' > plugins.txt
```

# Initial setup

The e-mail configuration will need to be updated with the correct smtp settings before launching jobs.

```
Manage Jenkins > Configure system > E-mail notification > Advanced
```

For the Gmail SMTP, these are:

```
SMTP server: smtp.gmail.com
(/) Use SMTP Authentication
User Name: alex@gmail.com
Password: ******
(/) Use SSL
SMTP Port: 465
Charset: UTF-8
```
