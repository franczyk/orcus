class ParentInstancesController < ApplicationController
  # GET /parent_instances
  # GET /parent_instances.xml
  def index
    @parent_instances = ParentInstance.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @parent_instances }
    end
  end

  # GET /parent_instances/1
  # GET /parent_instances/1.xml
  def show
    @parent_instance = ParentInstance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @parent_instance }
    end
  end

  # GET /parent_instances/new
  # GET /parent_instances/new.xml
  def new
    @parent_instance = ParentInstance.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @parent_instance }
    end
  end

  # GET /parent_instances/1/edit
  def edit
    @parent_instance = ParentInstance.find(params[:id])
  end

  # POST /parent_instances
  # POST /parent_instances.xml
  def create
    @parent_instance = ParentInstance.new(params[:parent_instance])

    respond_to do |format|
      if @parent_instance.save
        format.html { redirect_to(@parent_instance, :notice => 'ParentInstance was successfully created.') }
        format.xml  { render :xml => @parent_instance, :status => :created, :location => @parent_instance }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @parent_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /parent_instances/1
  # PUT /parent_instances/1.xml
  def update
    @parent_instance = ParentInstance.find(params[:id])

    respond_to do |format|
      if @parent_instance.update_attributes(params[:parent_instance])
        format.html { redirect_to(@parent_instance, :notice => 'ParentInstance was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @parent_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /parent_instances/1
  # DELETE /parent_instances/1.xml
  def destroy
    @parent_instance = ParentInstance.find(params[:id])
    @parent_instance.destroy

    respond_to do |format|
      format.html { redirect_to(parent_instances_url) }
      format.xml  { head :ok }
    end
  end
end
