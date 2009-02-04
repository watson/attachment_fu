namespace :attachment_fu do
  desc "Regenerate the thumbnails belonging to the models supplied with the MODELS environment variable (seperate with comma)"
  task :regenerate_thumbnails => :environment do
    if ENV['MODELS'].nil?
      puts "ERROR: You have to set the MODELS environment variable!"
    else
      ENV['MODELS'].split(',').each do |model|
        with_thumbnails = eval(model).all(:conditions => {:parent_id => nil})
        printf "Regenerating all %s thumbnails (%s total): ", model, with_thumbnails.size
        STDOUT.flush
        with_thumbnails.each do |r|
          if r.respond_to?(:process_attachment_with_processing) && r.thumbnailable? && !r.attachment_options[:thumbnails].blank? && r.parent_id.nil?
            temp_file = r.create_temp_file
            r.attachment_options[:thumbnails].each do |suffix, value|
              if value.is_a?(Hash)
                r.create_or_update_thumbnail(temp_file, suffix, *value[:size], &value[:proc])
              else
                r.create_or_update_thumbnail(temp_file, suffix, *value)
              end
            end
            print '.'
          else
            print '!'
          end
          STDOUT.flush
        end
        puts
      end
    end
  end
end