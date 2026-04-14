gnome = import('gnome')


stasks_resources = gnome.compile_resources(
  'stasks-resources',
  'stasks.gresource.xml',
  source_dir: '.'
)


install_data('com.ixsvf.stasks.desktop',
  install_dir: get_option('datadir') / 'applications'
)


install_data('icons/scalable/apps/com.ixsvf.stasks.svg',
  install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps'
)