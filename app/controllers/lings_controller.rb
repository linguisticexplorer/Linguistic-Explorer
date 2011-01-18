class LingsController < ApplicationController

  # GET /lings
  # GET /lings.xml
  def index
    @lings = Ling.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lings }
    end
  end

  # GET /lings/1
  # GET /lings/1.xml
  def show
    @ling = Ling.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ling }
    end
  end

  # GET /lings/new
  # GET /lings/new.xml
  def new
    @ling = Ling.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ling }
    end
  end

  # GET /lings/1/edit
  def edit
    @ling = Ling.find(params[:id])
  end

  # POST /lings
  # POST /lings.xml
  def create
    @ling = Ling.new(params[:ling])

    respond_to do |format|
      if @ling.save
        format.html { redirect_to(@ling, :notice => 'Ling was successfully created.') }
        format.xml  { render :xml => @ling, :status => :created, :location => @ling }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lings/1
  # PUT /lings/1.xml
  def update
    @ling = Ling.find(params[:id])

    respond_to do |format|
      if @ling.update_attributes(params[:ling])
        format.html { redirect_to(@ling, :notice => 'Ling was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lings/1
  # DELETE /lings/1.xml
  def destroy
    @ling = Ling.find(params[:id])
    @ling.destroy

    respond_to do |format|
      format.html { redirect_to(lings_url) }
      format.xml  { head :ok }
    end
  end
end
