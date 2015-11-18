{% set cfg_repos = pillar.get('apt_repos', {}) %}

{%- for repository in cfg_repos %}
  {%- for repo in repository %}
repository-{{ repo }}:
  file.managed:
    - name: /etc/apt/sources.list.d/{{ repo }}.list
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
    {%- for parameter in repository[repo] %}
        {{ parameter }}: {{ repository[repo][parameter] }}
    {%- endfor %}
  {%- endfor %}
{%- endfor %}

update-repository:
  cmd.wait:
    - name: aptitude update
    - cwd: /
    - watch:
      - file: /etc/apt/sources.list.d/*
    - order: 2
    
{%- if salt[pillar.get]('apt_option:clean_sources_list', False) %}
repository-clean-sourceslist:
  file.absent:
    - name: /etc/apt/sources.list
    - order: 1
{%- endif %}
