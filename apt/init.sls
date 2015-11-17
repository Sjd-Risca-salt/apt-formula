{% import_yaml "apt/defaults.yaml" as default_settings %}

{% for repo in apt_repos %}
{% set parameter = salt['pillar.get'](
    'apt_repos':repo,
    default=default_settings.apt_defaults,
    merge=True
  )
%}

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
        comment: parameter[comment]
        uri: parameter[uri]
        codename: parameter[codename]
        components: parameter[components]
        sources: parameter[sources]
        enable: parameter[enable]
{% endfor %}

update-repository:
  cmd.wait:
    - name: aptitude update
    - cwd: /
    - watch:
      -file: /etc/apt/source.list.d/*
    - order: 2
    
