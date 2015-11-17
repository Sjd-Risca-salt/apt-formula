{% set cfg_repo = pillar_get('apt_repos', {}) %}

{% for repo in cfg_repos %}
repository-{{ repo }}:
  file.managed:
    - name: /etc/apt/source.list.d/{{ repo }}.list
    - source: salt://apt/files/sources.list
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - order: 1
    - defaults:
        comment: ''
        uri: http://ftp.de.debian.org/debian
        codename: jessie
        components: main
        sources: False
        enable: True
    - context:
{% for key, value in cfg_repo.repo.items() %}
        {{ key }}: {{ value }}
{% endfor %}
{% endfor %}

update-repository:
  cmd.wait:
    - name: aptitude update
    - cwd: /
    - watch:
      -file: /etc/apt/source.list.d/*
    - order: 2
    
