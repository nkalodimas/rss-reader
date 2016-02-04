class FeedsController < ApplicationController
  before_action :set_user_feed, only: [:show, :edit, :update, :destroy, :unsubscribe, :read]
  before_action :set_feed, only: [:subscribe]

  @@per_page = 10

  # GET /feeds
  # GET /feeds.json
  def index
    @feeds = current_user.subscriptions.ordered_by_title
    @entries = current_user.entries.for_user(current_user.id, @@per_page).paginate(page: params[:page], per_page: @@per_page).set_read_attribute
    @unread_entries_count = current_user.reads.where(read: false).count    
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
    @entries = @feed.entries.for_user(current_user.id, @@per_page).paginate(page: params[:page], per_page: @@per_page).set_read_attribute
    @unread_entries_count = @feed.entries.for_user(current_user.id,nil).where(reads: {read: false}).count
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
    @feeds = Feed.popular
    @user_feeds_ids = current_user.subscription_ids
  end

  # GET /feeds/1/edit
  def edit
  end

  # POST /feeds
  # POST /feeds.json
  def create
    result = Feed.add_new_feed_and_subscribe(feed_params[:link], current_user)
    if result
      flash[:success] = 'Feed was successfully created.'
      redirect_to root_path
    else
      flash[:danger] = "Incorrect url!"
      render :new
    end
  end

  # POST /feeds/1/subscribe
  def subscribe
    #@feed.subscribers << current_user
    if @feed.add_subscriber current_user #@feed.subscribers.exists? current_user.id
      flash[:success] = "You were successfully subscribed to #{@feed.title}."
    else
      flash[:danger] = "You could not be subscribed to #{@feed.title}."
    end
    redirect_to new_feed_path
    # todo: add errors to view
  end

  # POST /feeds/1/unsubscribe
  def unsubscribe
    if current_user.unsubscribe @feed
      flash[:success] = "You were successfully unsubscribed from #{@feed.title}."
    else
      flash[:danger] = "You could not be unsubscribed from #{@feed.title}."
    end
    redirect_to root_path
    # todo: add errors to view
  end

  # POST /feeds/1/entries/1/read
  def read
    read = ActiveRecord::Type::Boolean.new.type_cast_from_user(read_params)
    entry = @feed.entries.find params[:entry_id]
    Read.mark_as_read(current_user.id, entry.id, read)
    respond_to do |format|
      format.js { head :ok }
    end
  end

  # PATCH/PUT /feeds/1
  # PATCH/PUT /feeds/1.json
  def update
    respond_to do |format|
      if @feed.update(feed_params)
        format.html { redirect_to @feed, notice: 'Feed was successfully updated.' }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_url, notice: 'Feed was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_feed
      @feed = current_user.subscriptions.find(params[:id])
    end

    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def feed_params
      params.require(:feed).permit(:link)
    end

    def read_params
      params.require(:read)
    end
end
