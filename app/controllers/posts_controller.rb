class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def search
    #@date_test = params.to_unsafe_h.slice(:date)

    @search_results = Post.search_coordinates(params[:street1], params[:city1], params[:state1],
      params[:street2], params[:city2], params[:state2])
  end

  # GET /posts
  # GET /posts.json
  def index
    #visitor_latitude = request.location.latitude
    #visitor_longitude = request.location.longitude
    @visitor_latitude = 37.35138
    @visitor_longitude = -121.850291
    #@posts = Array.new
    @posts = Post.all
    @source_near_me = Array.new()
    get_this_post
    #Post.where(:id => Addresses.full_address.near(visitor_latitude, visitor_longitude).post_id)
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @addresses = @post.addresses
    @iframe_src = @post.set_iframe_src
  end

  #
  def get_this_post
   #temp = Address.near([@visitor_latitude, @visitor_longitude], 20)
   #temp = Post.all() 
   t = Post.all()
   limit = 8

   t.each do |temp1|
        dist = temp1.addresses.first().distance_to([@visitor_latitude, @visitor_longitude])
       
        if dist <= limit
          #@posts.push(temp1)
        end
   end

  end

  # GET /posts/new
  def new
    @added=false
    @post = Post.new
    @post.addresses.new
    @post.addresses.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.addresses_count = @post.addresses.count

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    @post.update_attribute(:addresses_count, @post.addresses.count)
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:addresses_count, :title, :description, :date, 
        addresses_attributes: [:id, :street, :city, :state, :zip, :_destroy])
    end

end
