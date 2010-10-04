class AutomationsController < ApplicationController
  # GET /automations
  # GET /automations.xml
  def index
    @automations = Automation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @automations }
    end
  end

  # GET /automations/1
  # GET /automations/1.xml
  def show
    @automation = Automation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @automation }
    end
  end

  # GET /automations/new
  # GET /automations/new.xml
  def new
    @automation = Automation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @automation }
    end
  end

  # GET /automations/1/edit
  def edit
    @automation = Automation.find(params[:id])
  end

  # POST /automations
  # POST /automations.xml
  def create
    @automation = Automation.new(params[:automation])

    respond_to do |format|
      if @automation.save
        format.html { redirect_to(@automation, :notice => 'Automation was successfully created.') }
        format.xml  { render :xml => @automation, :status => :created, :location => @automation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @automation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /automations/1
  # PUT /automations/1.xml
  def update
    @automation = Automation.find(params[:id])

    respond_to do |format|
      if @automation.update_attributes(params[:automation])
        format.html { redirect_to(@automation, :notice => 'Automation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @automation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /automations/1
  # DELETE /automations/1.xml
  def destroy
    @automation = Automation.find(params[:id])
    @automation.destroy

    respond_to do |format|
      format.html { redirect_to(automations_url) }
      format.xml  { head :ok }
    end
  end
end
