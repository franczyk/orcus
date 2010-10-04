class HostPoolmapsController < ApplicationController
  # GET /host_poolmaps
  # GET /host_poolmaps.xml
  def index
    @host_poolmaps = HostPoolmap.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @host_poolmaps }
    end
  end

  # GET /host_poolmaps/1
  # GET /host_poolmaps/1.xml
  def show
    @host_poolmap = HostPoolmap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @host_poolmap }
    end
  end

  # GET /host_poolmaps/new
  # GET /host_poolmaps/new.xml
  def new
    @host_poolmap = HostPoolmap.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @host_poolmap }
    end
  end

  # GET /host_poolmaps/1/edit
  def edit
    @host_poolmap = HostPoolmap.find(params[:id])
  end

  # POST /host_poolmaps
  # POST /host_poolmaps.xml
  def create
    @host_poolmap = HostPoolmap.new(params[:host_poolmap])

    respond_to do |format|
      if @host_poolmap.save
        format.html { redirect_to(@host_poolmap, :notice => 'HostPoolmap was successfully created.') }
        format.xml  { render :xml => @host_poolmap, :status => :created, :location => @host_poolmap }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @host_poolmap.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /host_poolmaps/1
  # PUT /host_poolmaps/1.xml
  def update
    @host_poolmap = HostPoolmap.find(params[:id])

    respond_to do |format|
      if @host_poolmap.update_attributes(params[:host_poolmap])
        format.html { redirect_to(@host_poolmap, :notice => 'HostPoolmap was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @host_poolmap.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /host_poolmaps/1
  # DELETE /host_poolmaps/1.xml
  def destroy
    @host_poolmap = HostPoolmap.find(params[:id])
    @host_poolmap.destroy

    respond_to do |format|
      format.html { redirect_to(host_poolmaps_url) }
      format.xml  { head :ok }
    end
  end
end
