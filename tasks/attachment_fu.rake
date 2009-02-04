namespace :attachment_fu do
  desc "Regenerate the thumbnails belonging to the models supplied with the 'models' environment variable"
  task :regenerate_thumbnails => :environment do
    ENV['models'].split(',').each do |model|
      print "Regenerating all #{model} thumbnails"
      with_thumbnails = eval(model).all.select {|p| p.thumbnails.size <= 1 }
      print " (#{with_thumbnails.size} total): "
      with_thumbnails.each do |r|
        if p.data
          print '.'
        else
          print '!'
          next
        end
        temp_file = p.create_temp_file
        p.attachment_options[:thumbnails].each do |suffix, value|
          if value.is_a?(Hash)
            create_or_update_thumbnail(temp_file, suffix, *value[:size], &value[:proc])
          else
            create_or_update_thumbnail(temp_file, suffix, *value)
          end
        end
      end
      puts
    end
  end
end