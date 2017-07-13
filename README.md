ansible-module-devel
====================

Forked from https://github.com/schwartzmx/ansible-module-devel.git

This is where my work on ansible modules will be done before submitting PRs to https://github.com/ansible/ansible-modules-extras

#####Current module dev:
- Windows
  - `win_acl`
    - set file/directory permissions for user/group
  - `win_host`
    - host renaming and domain joining
  - `win_pscx`
    - install pscx (if needed), runs pscx commands
  - `win_s3`
    - download/upload to aws_s3
  - `win_timezone`
    - machine timezone setting via tzutil
  - `win_unzip`
    - unzip compressed files/folders
  - `win_zip`
    - compress files/folders

#####MRM Modules:
  - `mrm_cfg`
    - provides services data on all MRM application servers for MRM Service Report  
    
#####To use in your playbooks:
From your root directory (Where you run your playbooks from):
```
	mkdir library && cd library
	git clone https://github.com/kedwards/ansible-module-devel.git
```

And that is it... You should be able to use the modules.  Ansible should be able to find them.

If ansible comlains about:

` ERROR! no action detected in task. This often indicates a misspelled module name, or incorrect module path. `

add the following to your ansible.cfg file:

[defaults]  
library = library/


