class ForbesUsersController < ApplicationController
  # GET /forbes_users
  # GET /forbes_users.json
  def index
    @forbes_users = ForbesUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @forbes_users }
    end
  end

  # GET /forbes_users/1
  # GET /forbes_users/1.json
  def show
    @forbes_user = ForbesUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @forbes_user }
    end
  end

  # GET /forbes_users/new
  # GET /forbes_users/new.json
  def new
    @forbes_user = ForbesUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @forbes_user }
    end
  end

  # GET /forbes_users/1/edit
  def edit
    @forbes_user = ForbesUser.find(params[:id])
  end

  # POST /forbes_users
  # POST /forbes_users.json
  def create
    @forbes_user = ForbesUser.new(params[:forbes_user])

    respond_to do |format|
      if @forbes_user.save
        format.html { redirect_to @forbes_user, notice: 'Forbes user was successfully created.' }
        format.json { render json: @forbes_user, status: :created, location: @forbes_user }
      else
        format.html { render action: "new" }
        format.json { render json: @forbes_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /forbes_users/1
  # PUT /forbes_users/1.json
  def update
    @forbes_user = ForbesUser.find(params[:id])

    respond_to do |format|
      if @forbes_user.update_attributes(params[:forbes_user])
        format.html { redirect_to @forbes_user, notice: 'Forbes user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @forbes_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forbes_users/1
  # DELETE /forbes_users/1.json
  def destroy
    @forbes_user = ForbesUser.find(params[:id])
    @forbes_user.destroy

    respond_to do |format|
      format.html { redirect_to forbes_users_url }
      format.json { head :no_content }
    end
  end
end
