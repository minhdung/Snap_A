class PhotosController < ApplicationController
	before_filter :signed_in_user, only: [:new, :create, :destroy, :update, :edit]
	before_filter :authenticated_user, only: [:facebook]

	def new
		@photo=Photo.new
	end

	def url
		@photo=Photo.new
	end

	def facebook		
		token = current_user.authentications.find_by_provider('facebook').access_token
      	client = FBGraph::Client.new(:client_id => GRAPH_APP_ID, :secret_id => GRAPH_SECRET, :token => token)
        photos =client.selection.me.photos.limit(0).info!
        @links = photos.data.data.map(&:source)
	end

	def create
		@photo=Photo.new(params[:photo])
		if @photo.save
			flash[:success] = "Upload new photo successfully"
			redirect_to root_path
		else
			flash[:error] = "Wrong URL"
			redirect_to upload_path
		end
	end

	def authenticated_user
			redirect_to root_path unless !current_user.authentications.find_by_provider('facebook').nil?
	end


end
