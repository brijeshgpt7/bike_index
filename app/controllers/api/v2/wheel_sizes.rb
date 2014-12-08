module API
  module V2
    class WheelSizes < API::V2::Root
      include API::V2::Defaults

      resource :wheel_sizes do
        desc "All the wheels sizes with pagination (optionally sorted by popularity)", {
          notes: <<-NOTE
            We identify wheel sizes by ISO - if you'd like to learn more about ISO, check out [Sheldon Brown's article on tire-sizing](http://sheldonbrown.com/tire-sizing.html#iso).

            We include all the ISO BSD sizes we've found. You can choose get an abbreviated list by passing a `popularity`. Since wheel sizes frequently have similar names, we recommend only offering standard and common sizes unless prompted for more).
          NOTE
        }
        params do 
          optional :popularity, type: String, desc: 'Commonness of wheel sizes to include', values: WheelSize.popularities
        end
        get '/', protected: false do
          priority = WheelSize.popularities.index(params[:popularity])
          if priority.present?
            wheel_sizes = WheelSize.where(priority: (priority + 1))
          else
            wheel_sizes = WheelSize.scoped
          end
          paginate wheel_sizes
        end
      
        desc "Wheel size and description from iso_bsd", {
          notes: <<-NOTE
            Request information about a wheel size by it's [ISO BSD](http://sheldonbrown.com/tire-sizing.html#iso)
          NOTE
        }
        params do
          requires :id, type: Integer, desc: 'Wheel Size ISO BSD'
        end
        get ':id', protected: false do
          wheel_size = WheelSize.where(iso_bsd: params[:id])
          unless wheel_size.present?
            msg = "Unable to find wheel size with bsd: #{params[:id]}"
            raise ActiveRecord::RecordNotFound, msg
          end
          wheel_size.first
        end
      end

    end
  end
end