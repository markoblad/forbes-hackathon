class ForbesUsersController < ApplicationController
  # GET /forbes_users
  # GET /forbes_users.json
  def index
    # @forbes_users = ForbesUser.all

    @articles = []
    articles_hash = ForbesUser::ForbesUser::get_articles({})
    contacts = current_user.connections
    articles_hash["contentList"].each do |article_hash|
      unless article_hash["body"].blank?
        company_name = /\[entity display\=\".+?\"/.match(article_hash["body"]).to_s[17..-2]
        unless company_name.blank? || company_name.strip.blank?
          matching_contacts = []
          matching_contacts = contacts.select{|c| c["company"].upcase == company_name.upcase }
          # if matching_contacts.blank?
          #   [1,2,3,4,5].sample.times do |i|
          #     matching_contacts << contacts.sample
          #   end
          # end
          if matching_contacts.blank?
            company_names = []
            company_names = contacts.collect{|c| c["company"]}.compact
            closest_matches = []
            closest_matches = begin ForbesUser.return_closest_levenshtein_names(company_name, company_names).compact rescue [] end
            # closest_matches = begin ForbesUser.return_closest_white_names(company_name, company_names).compact rescue [] end
            matching_contacts = contacts.select{|c| closest_matches.include?(c["company"])} unless closest_matches.blank?
          end
          
          reconstructed_article_hash = {}
          reconstructed_article_hash.merge!({"stub" => article_hash["description"]})
          reconstructed_article_hash.merge!({"title" => article_hash["title"]})
          reconstructed_article_hash.merge!({"body" => begin article_hash["body"].gsub(/\[.*?\]/, '') rescue nil end })
          reconstructed_article_hash.merge!({"published_date" => begin Time.at(article_hash["timestamp"].to_f / 1000).strftime("%b %e, %Y") rescue "Dec 13, 2013" end })
          reconstructed_article_hash.merge!({"published_time" => begin Time.at(article_hash["timestamp"].to_f / 1000).strftime("%l:%M %P") rescue "20:13:28 -0500" end })
          reconstructed_article_hash.merge!({"forbes_url" => article_hash["uri"]})
          reconstructed_article_hash.merge!({"author" => begin article_hash["authors"][0]["name"] rescue "RJ Lehman" end })
          article_body = Sanitize.clean(begin article_hash["body"].gsub(/\[.*?\]/, '') rescue nil end)
          sentiment_score = begin SentimentAnalysis::sentiment_calculator(article_body, options) rescue 0.0 end
          reconstructed_article_hash.merge!({"sentiment_score" => sentiment_score})

          company_identifier = /key\=\".+?\"/.match(article_hash["body"]).to_s[5..-2]
          forbes_url = "http://www.forbes.com/companies/#{company_identifier}/"
          company_hash = {}
          company_hash = {
            "name" => company_name,
            "forbes_url" => forbes_url,
            "contacts" => matching_contacts
          }
          reconstructed_article_hash.merge!({"company" => company_hash})
          @articles << reconstructed_article_hash
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @articles }
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
