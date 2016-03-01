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
        enabled: True
    - context:
    {%- for parameter in repository[repo] %}
        {{ parameter }}: {{ repository[repo][parameter] }}
    {%- endfor %}
    {% if repository[repo][key] is defined %}
    {% set KEY = repository[repo][key] %}
repository-{{ repo }}-key:
  cmd.run:
    - names:
      - apt-key adv --keyserver keyserver.ubuntu.com --recv-keys {{ KEY }}
    - unless: apt-key adv --list-public-keys --with-fingerprint --with-colons | grep {{ KEY }}
    {% endif %}
  {%- endfor %}
{%- endfor %}

update-repository:
  cmd.wait:
    - name: aptitude update
    - cwd: /
    - watch:
      - file: /etc/apt/sources.list.d/*
    - order: 2
    
{%- if salt['pillar.get']('apt_option:clean_sources_list', False) %}
repository-clean-sourceslist:
  file.absent:
    - name: /etc/apt/sources.list
    - order: 1
{%- endif %}
{%- if salt['pillar.get']('apt_option:clean_preferences', False) %}
repository-clean-preferences:
  file.absent:
    - name: /etc/apt/preferences
    - order: 1
{%- endif %}

{%- if salt['pillar.get']('apt_pinning', False) %}
{%- for file in pillar.get('apt_pinning') %}
repository_pinning-{{ file }}:
  file.managed:
    - name: /etc/apt/preferences.d/{{ file }}
    - source: salt://apt/files/preferences
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - order: 1
    - defaults:
        file: {{ file }}
{% endfor %}
{%- endif %}
