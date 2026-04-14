

project('stasks', ['c', 'vala'],
          version: '1.0',
    meson_version: '>= 0.59.0',
  default_options: [ 'warning_level=2', 'werror=false', ],
)

dependency('glib-2.0')
dependency('gobject-2.0')
dependency('gtk4')
dependency('libadwaita-1')

i18n = import('i18n')

add_project_arguments('-DGETTEXT_PACKAGE="stasks"', language: 'c')

subdir('data')
subdir('src')
subdir('po')
