class ChainInstancesController < ApplicationController
  # GET /chain_instances
  # GET /chain_instances.xml
  def index
    @chain_instances = ChainInstance.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @chain_instances }
    end
  end

  # GET /chain_instances/1
  # GET /chain_instances/1.xml
  def show
    @chain_instance = ChainInstance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @chain_instance }
    end
  end

  # GET /chain_instances/new
  # GET /chain_instances/new.xml
  def new
    @chain_instance = ChainInstance.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @chain_instance }
    end
  end

  # GET /chain_instances/1/edit
  def edit
    @chain_instance = ChainInstance.find(params[:id])
  end

  # POST /chain_instances
  # POST /chain_instances.xml
  def create
    @chain_instance = ChainInstance.new(params[:chain_instance])

    respond_to do |format|
      if @chain_instance.save
        format.html { redirect_to(@chain_instance, :notice => 'Chain instance was successfully created.') }
        format.xml  { render :xml => @chain_instance, :status => :created, :location => @chain_instance }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @chain_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /chain_instances/1
  # PUT /chain_instances/1.xml
  def update
    @chain_instance = ChainInstance.find(params[:id])

    respond_to do |format|
      if @chain_instance.update_attributes(params[:chain_instance])
        format.html { redirect_to(@chain_instance, :notice => 'Chain instance was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @chain_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /chain_instances/1
  # DELETE /chain_instances/1.xml
  def destroy
    @chain_instance = ChainInstance.find(params[:id])
    @chain_instance.destroy

    respond_to do |format|
      format.html { redirect_to(chain_instances_url) }
      format.xml  { head :ok }
    end
  end
end
