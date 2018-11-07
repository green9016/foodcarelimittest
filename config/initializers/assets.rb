# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Add here assets used on a particular page. They need to be precompiled
Rails.application.config.assets.precompile += %w( components-jqueryui/jquery-ui.js )
Rails.application.config.assets.precompile += %w( jqueryui-touch-punch/jquery.ui.touch-punch.min )
Rails.application.config.assets.precompile += %w( x-editable/dist/bootstrap3-editable/css/bootstrap-editable.css )
Rails.application.config.assets.precompile += %w( x-editable/dist/bootstrap3-editable/js/bootstrap-editable.min.js )

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
